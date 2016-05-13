defmodule Plugs.Authorized do
  import Plug.Conn
  import Phoenix.Controller, only: [action_name: 1]
  import Ecto.Query, only: [from: 2]

  def init(options) do
    {model, attr} = options[:preload]
    # Application.get_env(:addict, :not_logged_in_url, "/error")
    {Fulcrum.Repo, model, attr}
  end

  def call(conn, opts) do
    case  action_name(conn) do
      :index ->
        preload_authorized_index(conn, opts)
      :show ->
        preload_authorized_singular(conn, opts)
      :edit ->
        preload_authorized_singular(conn, opts)
      :update ->
        preload_authorized_singular(conn, opts)
      :delete ->
        preload_authorized_singular(conn, opts)
      _ ->
        conn
    end
  end

  defp preload_authorized_index(conn, {repo, klass, attr_id}) do
    id = conn.assigns.current_user
    id = if is_map(id), do: id.id, else: id
    query = from o in klass, where: field(o, ^attr_id) == ^id
    assign(conn, :resource, repo.all(query))
  end

  defp preload_authorized_singular(conn, {repo, klass, attr_id}) do
    attr_id_value = conn.assigns.current_user
    attr_id_value = if is_map(attr_id_value), do: attr_id_value.id, else: attr_id_value
    assign(conn, :resource, repo.get_by!(
      klass, [{:id, conn.params["id"]}, {attr_id, attr_id_value}]))
  end
end
