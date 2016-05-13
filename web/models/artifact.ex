# Could be a docker volume or an uploaded S3 backup or a DNS setting in 
# namecheap 
defmodule Fulcrum.Artifact do
  use Fulcrum.Web, :model

  schema "artifacts" do
    belongs_to :owner,     Fulcrum.Owner
    belongs_to :component, Fulcrum.Component
    belongs_to :instance,  Fulcrum.Instance

    field :associated_instance_ids, {:array, :string}
    field :type, :string
    field :name, :string
    field :properties, :map

    timestamps
  end

  @required_fields ~w(owner component associated_instance_ids type name properties)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
