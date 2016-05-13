defmodule Fulcrum.PageController do
  use Fulcrum.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
