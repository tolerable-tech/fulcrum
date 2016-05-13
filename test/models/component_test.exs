defmodule Fulcrum.ComponentTest do
  use Fulcrum.ModelCase

  alias Fulcrum.Component

  @valid_attrs %{access_url: "some content", config: "some content", description: "some content", name: "some content", webpage: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Component.changeset(%Component{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Component.changeset(%Component{}, @invalid_attrs)
    refute changeset.valid?
  end
end
