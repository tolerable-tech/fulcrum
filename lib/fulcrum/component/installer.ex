defmodule Fulcrum.Component.Installer do
  alias Fulcrum.Component
  alias Fulcrum.Repo

  @name __MODULE__

  def call(url) do
    Task.async(@name, :async_install, [url])
  end

  def async_install(url) do
    case install(url) do
      {:ok, component} ->
        changeset = Component.changeset(component, %{state: "ready_to_launch"})
        Repo.update(changeset)
      {:error, errors} ->
        IO.puts "fuck!! #{inspect(errors)}"
    end
  end

  # fetch Plugin description JSON, ensure we have the dependencies,
  # generate fleet files to them, dispatch to fleet.
  def install(url) when is_binary(url) do
    Component.Index.fetch(url) |> install
  end
  def install(nition = %Component{}) do
    nition
    |> require_dependencies
    |> map_return
    # moved to Instance.Launcher
    #|> generate_fleet_files
    #|> dispatch_fleet_files
  end

  def require_dependencies(nition = %Component{}) do
    # for now, each required instance of a dependency gets a fleet instance, but
    # we only list the component once?
    #
    # generate component records marked as dependents
    # generate dependency records for main component
    installs = Enum.map(Component.missing_components(nition), fn(name) ->
      case Component.Index.find_params(name) do
        {:ok, dep_nition} ->
          dep_nition = Map.put_new(dep_nition, "installation_type", "dependency")
          dep_nition = Map.put_new(dep_nition, "owner_id", nition.owner_id)
          {:ok, dep_comp} = Repo.insert(Component.changeset(%Component{}, dep_nition))
          @name.install(dep_comp)
        {:error, {:not_found, body}} ->
          IO.puts "Cound not find spec:  #{name} [ #{body} ]"
        {:error, error} ->
          IO.puts "Could not fetch spec: #{name} [#{IO.inspect(error)}]"
      end
    end)
    {nition, installs}
  end

  def map_return({nition, list}) do
    case Enum.reject(list, fn(item) -> 
      case item do
        {:ok, _dontdare} -> true
        {:error, err} ->
          err
      end
    end) do
      [] ->
        {:ok, nition}
      list ->
        {:error, list}
    end
  end

end
