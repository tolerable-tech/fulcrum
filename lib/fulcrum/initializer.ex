defmodule Fulcrum.Initializer do
  use GenServer

  alias Fulcrum.Settings
  alias Fulcrum.Initializer.Inviter
  alias Fulcrum.Initializer.MigrationDispatcher
  import Fulcrum.Settings, only: [etcd_api_url: 1]
  import Ecto.Query, only: [from: 2]
  import Ecto.Query.API, only: [count: 1, count: 2]

  @name __MODULE__
  @unready_stati [:pending_dns, :pending_db, :pending_owner, :unmigrated, :pending_migrations]

  def start_link() do
    GenServer.start_link(@name, [], name: @name)
  end

  def init(_args) do
    # Since we're starting Fulcrum.Repo under the same supervisor this is running
    # under, we have to call Supervisor.start_child _after_ this Supervisor is running,
    # which means _after_ this #init function is complete. ughughugh amirite
    GenServer.cast(@name, :initial_setup)
    {:ok, {:ur_mom}}
  end

  # PUBLIC API

  def up? do
    status == :up
  end

  def state do
    GenServer.call(@name, :state)
  end

  def status do
    GenServer.call(@name, :status)
  end

  def validate(nonce) do
    GenServer.call(@name, {:validate, nonce})
  end

  def dns_availability_confirmed do
    GenServer.cast(@name, {:dns_availability_confirmed})
  end

  def owner_created(owner_id) do
    GenServer.cast(@name, {:owner_created, owner_id})
  end

  # IMPLEMENTATIONS

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:status, _from, state = %{status: :pending_migrations}) do
    case is_migrated? do
      true ->
        state = %{state | status: :migrated}
        {:reply, :migrated, state}
      _ -> {:reply, :unmigrated, state}
    end
  end
  def handle_call(:status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call({:validate, nonce}, _from, state) do
    case Map.get(state, :nonce, SecureRandom.hex(20)) do
      ^nonce ->
        {:reply, :valid, state}
      out -> 
        {:reply, :invalid, state}
    end
  end

  def handle_cast(:initial_setup, _useless_state) do
    set_postgres_config_from_env_and_start_repo_worker
    set_nginx_keys_in_etcd
    state = system_stats
            |> launch_migrations
            |> send_invite_email
            |> write_s3_creds
            #|> launch_appropriate_endpoint

    IO.inspect state
    if state.status == :pending_dns do
      state |> Map.put(:dns_poll_task, Fulcrum.Initializer.DnsPoller.setup_poll)
    end
    {:noreply, state}
  end

  def handle_cast({:owner_created, id}, state) do
    state = Map.put(state, :status, :up)
            |> Map.put(:owner_id, id)
            |> write_s3_creds
    {:noreply, state}
  end

  def handle_cast({:dns_availability_confirmed}, state) do
    Fulcrum.SslManager.enable
    {:noreply, system_stats |> Map.put(:nonce, Map.get(state, :nonce))}
  end

  defp system_stats do
    d = is_dnsd?
    m = is_migrated?
    o = has_owner?(m)

    # Roughly in order that we wait on things
    s = cond do
      m && o && d -> :up
      !d          -> :pending_dns
      !m          -> :unmigrated  # is changed to pending_migrations in launch_migrations/1
      !o          -> :pending_owner
      true        -> :pending_db
    end

    %{sup: nil,
      migrations: m,
      owners: o,
      status: s
    }
  end

  defp is_dnsd? do
    Fulcrum.Initializer.DnsPoller.is_available?
  end

  defp is_migrated? do
    try do
      Fulcrum.Repo.get(Fulcrum.Owner, 1)
      true
    rescue
      _ -> false
    end
  end

  defp launch_migrations(%{status: :unmigrated} = state) do
    MigrationDispatcher.run
    %{state | status: :pending_migrations}
  end
  defp launch_migrations(state) do
    # WE go ahead an run migrations to pick up any changes
    # unfortunately we currently have no way of having this reflected in the state
    # because we have no wy for the migration runner to report back when its done.
    MigrationDispatcher.run
    state
  end

  defp send_invite_email(%{nonce: nonce} = state), do: state
  defp send_invite_email(%{owners: true} = state), do: state
  defp send_invite_email(state) do
    Map.put(state, :nonce, Inviter.run)
  end

  defp has_owner?, do: false
  defp has_owner?(false), do: false
  defp has_owner?(true) do
    case Fulcrum.Repo.all(from o in Fulcrum.Owner, select: count(o.id)) do
      [0] -> false
      _ -> true
    end
    false
  end

  defp write_s3_creds(%{status: status} = state) when status in @unready_stati, do: state
  defp write_s3_creds(state) do
    case Fulcrum.Settings.s3_env_vars do
      %{"id" => nil} -> state
      settings ->
        rec = %Fulcrum.Specifier{name: "s3-credentials", owner_id: state.owner_id,
          value_map: settings}
        Fulcrum.Repo.insert(rec)
        state
    end
  end

  defp set_postgres_config_from_env_and_start_repo_worker do
    [user, pass, db] = Settings.postgres_config

    Application.put_env(:fulcrum, Fulcrum.Repo,
      adapter: Ecto.Adapters.Postgres,
      username: user, password: pass, database: db,
      hostname: "fulcrum_postgresql.fulcrum-private",
      pool_size: 20) # The amount of database connections in the pool

    Supervisor.start_child(Fulcrum.Supervisor,
      Supervisor.Spec.worker(Fulcrum.Repo, []))
  end

  defp set_nginx_keys_in_etcd do
    put_key("/apps/fulcrum/1", "fulcrum-app.fulcrum-private:4000")
    put_key("/apps/fulcrum/ssl", "redirect")
    etcd_mkdir("/apps/fulcrum/vhost")

    case get_etcd_keys("/apps/fulcrum/vhost") do
      [] ->
        get_etcd_key("/le/others")
        |> String.split(",")
        |> Enum.each(fn(name) -> post_key("/apps/fulcrum/vhost", name) end)
      _ ->
        :ok
    end
  end

  defp etcd_mkdir(name) do
    etcd_api_url("/v2/keys#{name}?dir=true")
    |> HTTPoison.put!("")
  end

  defp post_key(name, value) do
    etcd_api_url("/v2/keys#{name}?value=#{value}")
    |> HTTPoison.post!("value=#{value}")
  end

  defp put_key(name, value) do
    etcd_api_url("/v2/keys#{name}?value=#{value}")
    |> HTTPoison.put!("value=#{value}")
  end

  defp get_etcd_key(name) do
    resp = etcd_api_url("/v2/keys#{name}")
    |> HTTPoison.get
    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case body |> Poison.decode do
          {:ok, values} ->
            values |> Dict.get("node") |> Dict.get("value")
          error -> ""
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        ""
    end
  end

  defp get_etcd_keys(name) do
    resp = etcd_api_url("/v2/keys#{name}")
    |> HTTPoison.get
    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case body |> Poison.decode do
          {:ok, %{"nodes" => values}} ->
            values |> Enum.map(fn(dict) -> {Dict.get(dict, "key"), Dict.get(dict, "value")} end)
          {:ok, _} -> []
          error -> []
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        []
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        []
    end
  end
end
