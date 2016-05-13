defmodule Fulcrum.InitialSetup.TokenValidatorControllerTest do
  use Fulcrum.ConnCase

  alias Fulcrum.InitialSetup.TokenValidator
  @valid_attrs %{}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, token_validator_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing validators"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, token_validator_path(conn, :new)
    assert html_response(conn, 200) =~ "New token validator"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, token_validator_path(conn, :create), token_validator: @valid_attrs
    assert redirected_to(conn) == token_validator_path(conn, :index)
    assert Repo.get_by(TokenValidator, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, token_validator_path(conn, :create), token_validator: @invalid_attrs
    assert html_response(conn, 200) =~ "New token validator"
  end

  test "shows chosen resource", %{conn: conn} do
    token_validator = Repo.insert! %TokenValidator{}
    conn = get conn, token_validator_path(conn, :show, token_validator)
    assert html_response(conn, 200) =~ "Show token validator"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, token_validator_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    token_validator = Repo.insert! %TokenValidator{}
    conn = get conn, token_validator_path(conn, :edit, token_validator)
    assert html_response(conn, 200) =~ "Edit token validator"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    token_validator = Repo.insert! %TokenValidator{}
    conn = put conn, token_validator_path(conn, :update, token_validator), token_validator: @valid_attrs
    assert redirected_to(conn) == token_validator_path(conn, :show, token_validator)
    assert Repo.get_by(TokenValidator, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    token_validator = Repo.insert! %TokenValidator{}
    conn = put conn, token_validator_path(conn, :update, token_validator), token_validator: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit token validator"
  end

  test "deletes chosen resource", %{conn: conn} do
    token_validator = Repo.insert! %TokenValidator{}
    conn = delete conn, token_validator_path(conn, :delete, token_validator)
    assert redirected_to(conn) == token_validator_path(conn, :index)
    refute Repo.get(TokenValidator, token_validator.id)
  end
end
