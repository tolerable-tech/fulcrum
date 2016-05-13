defmodule Fulcrum.ComponentController do
  use Fulcrum.Web, :controller

  alias Fulcrum.Component
  alias Fulcrum.Instance

  plug Addict.Plugs.Authenticated #when action in [:foobar]
  plug Plugs.Authorized, [preload: {Component, :owner_id}] when action in [:edit, :update, :show, :delete]
  plug :scrub_params, "component" when action in [:create, :update]

  def index(conn, %{"show_dependencies" => show_deps}) do
    components = Query.Component.index(show_dependents: show_deps,
                                       owner: conn.assigns.current_user)
    render(conn, "index.html", components: components)
  end
  def index(conn, params) do
    index(conn, Map.put_new(params, "show_dependencies", false))
  end

  def new(conn, _params) do
    changeset = Component.changeset(%Component{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"component" => component_params}) do
    component_params = Dict.put(component_params, "owner_id", conn.assigns.current_user.id)
      |> Dict.put_new("installation_type","requested")
    changeset = Component.changeset(%Component{}, component_params)

    case Repo.insert(changeset) do
      {:ok, _component} ->
        conn
        |> put_flash(:info, "Component created successfully.")
        |> redirect(to: component_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    specifications = Query.Specifier.pertaining_to(conn.assigns.resource)
    render(conn, "show.html", component: conn.assigns.resource, specifications: specifications)
  end

  def edit(conn, %{"id" => _id}) do
    component = conn.assigns.resource
    changeset = Component.changeset(component)
    configurables = Query.Specifier.pertaining_to(component, pad_empties: true)
    render(conn, "edit.html", component: component, changeset: changeset, configurables: configurables)
  end

  def update(conn, %{"id" => _id, "component" =>%{"state" => "ready_to_launch"}}) do
    component = conn.assigns.resource
    specifications = Query.Specifier.pertaining_to(conn.assigns.resource)
    case Component.Installer.call(component) do
      {:ok, component} ->
        conn
        |> put_flash(:info, "Component dependencies installed, ready to launch!")
        |> redirect(to: component_path(conn, :show, component))
      {:error, errors} ->
        conn
        |> put_flash(:info, "Hit a snag! #{errors}")
        |> render("show.html", component: component)
      something ->
        conn
        |> put_flash(:info, "Installing using PID #{inspect something}")
        |> render("show.html", component: component, specifications: specifications)
    end
  end
  def update(conn, %{"id" => _id, "component" => %{"state" => "launched"}}) do
    component = conn.assigns.resource
    instance = Instance.get(component)
    specifications = Query.Specifier.pertaining_to(conn.assigns.resource)

    case Instance.Launcher.call(instance) do
      {:ok, instance} -> 
        conn
        |> put_flash(:info, "Instance launched, here it is!")
        |> redirect(to: instance_path(conn, :show, instance))
      {:error, errors} ->
        conn
        |> put_flash(:info, "Failed to launch an instance, wtf? [#{inspect errors}]")
        |> render("show.html", component: component, specifications: specifications)
    end
  end
  def update(conn, %{"id" => _id, "component" => %{"state" => "stopped"}}) do
    component = conn.assigns.resource
    instance = Instance.get(component)

    case Instance.Remover.call(instance) do
      {:ok, instance} -> 
        conn
        |> put_flash(:info, "Instance stopped, here's its component")
        |> redirect(to: component_path(conn, :show, component))
      {:error, errors} ->
        conn
        |> put_flash(:info, "Failed to launch an instance, wtf? [#{errors}]")
        |> render("show.html", component: component)
    end
  end
  def update(conn, %{"id" => _id, "component" => %{"edit_page" => "configuration", "configurable" => configurations}}) do
    component = conn.assigns.resource

    case Fulcrum.Specifier.merge_for(component, configurations) do
      %{errors: []} ->
        conn
        |> put_flash(:info, "jake is amazing")
        |> redirect(to: component_path(conn, :show, component))
      %{errors: elist} ->
        conn
        |> put_flash(:info, "we hit some bumps: #{inspect elist}")
        |> render(conn, "edit.html", component: component,
                  changeset: Component.changeset(component, :empty))
    end
  end
  def update(conn, %{"id" => _id, "component" => component_params}) do
    component = conn.assigns.resource
    changeset = Component.changeset(component, component_params)

    case Repo.update(changeset) do
      {:ok, component} ->
        conn
        |> put_flash(:info, "Component updated successfully.")
        |> redirect(to: component_path(conn, :show, component))
      {:error, changeset} ->
        render(conn, "edit.html", component: component, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    component = conn.assigns.resource

    Fulcrum.Component.Deleter.call(component)

    conn
    |> put_flash(:info, "Component deleted successfully.")
    |> redirect(to: component_path(conn, :index))
  end
end
