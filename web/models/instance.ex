defmodule Fulcrum.Instance do
  use Fulcrum.Web, :model
  import Fulcrum.Component.Naming, only: [unit_name: 1]
  alias Fulcrum.Repo

  @required_fields ~w(owner_id component_id)
  @optional_fields ~w(required_by_id goal_id fleet_name desired_state envs)
  @fleet_stati ~w(launched stopped)

  schema "instances" do
    belongs_to :owner,           Fulcrum.Owner
    belongs_to :component,       Fulcrum.Component
    belongs_to :dependency_of,   Fulcrum.Component, foreign_key: :required_by_id
    has_many :linked_instances,  Fulcrum.Instance, on_delete: :delete_all, foreign_key: :linked_instance_id
    belongs_to :linked_instance, Fulcrum.Instance
    belongs_to :goal,            Fulcrum.Goal

    has_many :specifiers, Fulcrum.Specifier

    field :fleet_name,     :string
    field :container_name, :string
    field :desired_state,  :string, default: "stopped"
    field :envs,           :map,    default: %{}

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty)
  def changeset(model, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:desired_state, @fleet_stati)
    #|> validate_presence_of(:owner_id, :component_id)
  end

  @doc """
  Return an Instance of this Component owned by this person.

  If one doesn't exist in the DB, create one.
  """
  def get(comp = %Fulcrum.Component{}) do
    case Repo.get_by(Fulcrum.Instance, component_id: comp.id, owner_id: comp.owner_id) do
      nil ->
        {:ok, ins} = from_component(comp) |> Repo.insert
        ins
      instance ->
        instance
    end
  end

  @doc """
  Return an unsaved Instance for this Component
  """
  def from_component(comp = %Fulcrum.Component{}) do
    %__MODULE__{owner_id: comp.owner_id, component_id: comp.id}
  end

  def is_dependency?(%Fulcrum.Instance{required_by_id: nil}), do: false
  def is_dependency?(%Fulcrum.Instance{required_by_id: id}) when is_number(id), do: true

  def assign_fleet_name(ins = %__MODULE__{}) do
    %{ins | fleet_name: fleet_name_for(ins)}
  end

  def assign_container_name(ins = %__MODULE__{}) do
    n = "fulcrum_O-#{ins.component.owner_id}_#{ins.component.name}"
    if __MODULE__.is_dependency?(ins) do
      n = n <> "_#{ins.dependency_of.name}"
    end
    %{ins | container_name: n <> "_c"}
  end

  defp fleet_name_for(ins = %__MODULE__{required_by_id: id}) when is_number(id) do
    "O#{ins.owner_id}-#{ins.component.name}@#{ins.dependency_of.name}" |> unit_name
  end
  defp fleet_name_for(ins = %__MODULE__{required_by_id: nil}) do
    "O#{ins.owner_id}-#{ins.component.name}" |> unit_name
  end
end
