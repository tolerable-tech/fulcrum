defmodule Fulcrum.OwnerController do
  use Fulcrum.Web, :controller

  alias Fulcrum.Owner

  plug Addict.Plugs.Authenticated #when action in [:foobar]
  plug :scrub_params, "owner" when action in [:create, :update]

  def index(conn, _params) do
    owners = Repo.all(Owner)
    render(conn, "index.html", owners: owners)
  end

  def new(conn, _params) do
    changeset = Owner.changeset(%Owner{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"owner" => owner_params}) do
    changeset = Owner.changeset(%Owner{}, owner_params)

    if changeset.valid? do
      Repo.insert(changeset)

      conn
      |> put_flash(:info, "Owner created successfully.")
      |> redirect(to: owner_path(conn, :index))
    else
      render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    owner = Repo.get(Owner, id)
    render(conn, "show.html", owner: owner)
  end

  def edit(conn, %{"id" => id}) do
    owner = Repo.get(Owner, id)
    changeset = Owner.changeset(owner)
    render(conn, "edit.html", owner: owner, changeset: changeset)
  end

  def update(conn, %{"id" => id, "owner" => owner_params}) do
    owner = Repo.get(Owner, id)
    changeset = Owner.changeset(owner, owner_params)

    if changeset.valid? do
      Repo.update(changeset)

      conn
      |> put_flash(:info, "Owner updated successfully.")
      |> redirect(to: owner_path(conn, :index))
    else
      render(conn, "edit.html", owner: owner, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    owner = Repo.get(Owner, id)
    Repo.delete(owner)

    conn
    |> put_flash(:info, "Owner deleted successfully.")
    |> redirect(to: owner_path(conn, :index))
  end
end
