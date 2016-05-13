defmodule Fulcrum.LayoutView do
  use Fulcrum.Web, :view
   def current_user(conn) do
     Addict.Helper.current_user(conn)
  end

  def logged_in(conn) do
    current_user(conn) != nil
  end

  def current_user?(conn) do
    logged_in(conn)
  end

  def current_user_name(conn) do
    if Map.has_key?(conn.assigns, :current_user) do
      username(conn.assigns.current_user)
    else
      nil
    end
  end

  def username(id) when is_integer(id) do
    Fulcrum.Repo.get!(Fulcrum.Owner, id).username
  end

  def username(owner) when is_map(owner) do
    owner.username
  end

  def top_domain do
    Fulcrum.Settings.top_domain
  end
end
