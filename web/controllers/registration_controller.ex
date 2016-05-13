defmodule Fulcrum.RegistrationController do
  use Fulcrum.Web, :controller

  alias Fulcrum.Owner

  plug :scrub_params, "owner" when action in [:create, :update]

  def new(conn, _params) do
    changeset = Owner.changeset(%Owner{})
    render(conn, "new.html", changeset: changeset)
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
      |> redirect(to: owner_path(conn, :index, owner))
    else
      render(conn, "edit.html", owner: owner, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    owner = Repo.get(Owner, id)
    Repo.delete(owner)

    conn
    |> put_flash(:info, "Owner deleted successfully.")
    |> redirect(to: login_path(conn, :new))
  end
end
