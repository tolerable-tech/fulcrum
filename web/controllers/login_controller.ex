defmodule Fulcrum.LoginController do
  use Fulcrum.Web, :controller

  alias Fulcrum.Owner

  plug :scrub_params, "login" when action in [:create, :update]

  def new(conn, params) do
    redirect_path = Map.get(params, "redirect", Application.get_env(:addict, :redirect_string))
    changeset = Owner.changeset(%Owner{})
    render(conn, "new.html", changeset: changeset, redirect_path: redirect_path)
  end

end
