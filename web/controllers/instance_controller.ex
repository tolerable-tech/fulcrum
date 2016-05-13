defmodule Fulcrum.InstanceController do
  use Fulcrum.Web, :controller

  alias Fulcrum.Instance

  plug Addict.Plugs.Authenticated #when action in [:foobar]
  plug Plugs.Authorized, [preload: {Instance, :owner_id}] when action in [:edit, :update, :show, :delete]
  plug :scrub_params, "instance" when action in [:create, :update]

  def show(conn, %{"id" => id}) do
    instance = conn.assigns.resource |> Repo.preload(:component)
    specs = Query.Specifier.pertaining_to(instance)
    ispecs = Query.Specifier.pertaining_to(instance.component)
    render(conn, "show.html", instance: instance, specifications: specs, inspecs: ispecs)
  end

  def edit(conn, %{"id" => _id}) do
    instance = conn.assigns.resource
    changeset = Instance.changeset(instance)
    specs = Query.Specifier.pertaining_to(instance, pad_empties: true)

    render(conn, "edit.html", instance: instance, changeset: changeset, configurables: specs)
  end

  def update(conn, %{"id" => _id, "instance" => %{"edit_page" => "configuration", "configurable" => configurations}}) do
    instance = conn.assigns.resource

    case Fulcrum.Specifier.merge_for(instance, configurations) do
      %{errors: []} ->
        conn
        |> put_flash(:info, "jake is amazing")
        |> redirect(to: instance_path(conn, :show, instance))
      %{errors: elist} ->
        conn
        |> put_flash(:info, "we hit some bumps: #{inspect elist}")
        |> render(conn, "edit.html", instance: instance,
                  changeset: Component.changeset(instance, :empty))
    end
  end
  def update(conn, %{"id" => id, "instance" => instance_params}) do
    instance = Repo.get!(Instance, id)
    changeset = Instance.changeset(instance, instance_params)

    case Repo.update(changeset) do
      {:ok, instance} ->
        conn
        |> put_flash(:info, "Instance updated successfully.")
        |> redirect(to: instance_path(conn, :show, instance))
      {:error, changeset} ->
        render(conn, "edit.html", instance: instance, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    instance = Repo.get!(Instance, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(instance)

    conn
    |> put_flash(:info, "Instance deleted successfully.")
    |> redirect(to: instance_path(conn, :index))
  end
end
