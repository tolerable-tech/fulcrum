defmodule Fulcrum.AccompanimentTest do
  use Fulcrum.ModelCase

  alias Fulcrum.Accompaniment

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Accompaniment.changeset(%Accompaniment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Accompaniment.changeset(%Accompaniment{}, @invalid_attrs)
    refute changeset.valid?
  end
end
