defmodule Fulcrum.ComponentControllerTest do
  use Fulcrum.ConnCase

  alias Fulcrum.Component
  @valid_attrs %{access_url: "some content", config: "some content", description: "some content", name: "some content", webpage: "some content"}
  @invalid_attrs %{poop: :nugget}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, component_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing components"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, component_path(conn, :new)
    assert html_response(conn, 200) =~ "New component"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, component_path(conn, :create), component: @valid_attrs
    assert redirected_to(conn) == component_path(conn, :index)
    assert Repo.get_by(Component, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, component_path(conn, :create), component: @invalid_attrs
    assert html_response(conn, 200) =~ "New component"
  end

  test "shows chosen resource", %{conn: conn} do
    component = Repo.insert! %Component{}
    conn = get conn, component_path(conn, :show, component)
    assert html_response(conn, 200) =~ "Show component"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, component_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    component = Repo.insert! %Component{}
    conn = get conn, component_path(conn, :edit, component)
    assert html_response(conn, 200) =~ "Edit component"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    component = Repo.insert! %Component{}
    conn = put conn, component_path(conn, :update, component), component: @valid_attrs
    assert redirected_to(conn) == component_path(conn, :show, component)
    assert Repo.get_by(Component, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    component = Repo.insert! %Component{}
    conn = put conn, component_path(conn, :update, component), component: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit component"
  end

  test "deletes chosen resource", %{conn: conn} do
    component = Repo.insert! %Component{}
    conn = delete conn, component_path(conn, :delete, component)
    assert redirected_to(conn) == component_path(conn, :index)
    refute Repo.get(Component, component.id)
  end
end
