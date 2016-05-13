defmodule Fulcrum.ArtifactTest do
  use Fulcrum.ModelCase

  alias Fulcrum.Artifact

  @valid_attrs %{associated_instance_ids: [], component: "some content", name: "some content", owner: "some content", properties: %{}, type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Artifact.changeset(%Artifact{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Artifact.changeset(%Artifact{}, @invalid_attrs)
    refute changeset.valid?
  end
end
