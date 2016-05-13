defmodule Fulcrum.InstanceControllerTest do
  use Fulcrum.ConnCase

  alias Fulcrum.Instance
  @valid_attrs %{state: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  #test "lists all entries on index", %{conn: conn} do
    #conn = get conn, instance_path(conn, :index)
    #assert html_response(conn, 200) =~ "Listing instance"
  #end

  #test "renders form for new resources", %{conn: conn} do
    #conn = get conn, instance_path(conn, :new)
    #assert html_response(conn, 200) =~ "New instance"
  #end

  #test "creates resource and redirects when data is valid", %{conn: conn} do
    #conn = post conn, instance_path(conn, :create), instance: @valid_attrs
    #assert redirected_to(conn) == instance_path(conn, :index)
    #assert Repo.get_by(Instance, @valid_attrs)
  #end

  #test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    #conn = post conn, instance_path(conn, :create), instance: @invalid_attrs
    #assert html_response(conn, 200) =~ "New instance"
  #end

  test "shows chosen resource", %{conn: conn} do
    instance = Repo.insert! %Instance{}
    conn = get conn, instance_path(conn, :show, instance)
    assert html_response(conn, 200) =~ "Show instance"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, instance_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    instance = Repo.insert! %Instance{}
    conn = get conn, instance_path(conn, :edit, instance)
    assert html_response(conn, 200) =~ "Edit instance"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    instance = Repo.insert! %Instance{}
    conn = put conn, instance_path(conn, :update, instance), instance: @valid_attrs
    assert redirected_to(conn) == instance_path(conn, :show, instance)
    assert Repo.get_by(Instance, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    instance = Repo.insert! %Instance{}
    conn = put conn, instance_path(conn, :update, instance), instance: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit instance"
  end

  test "deletes chosen resource", %{conn: conn} do
    instance = Repo.insert! %Instance{}
    conn = delete conn, instance_path(conn, :delete, instance)
    assert redirected_to(conn) == instance_path(conn, :index)
    refute Repo.get(Instance, instance.id)
  end
end
