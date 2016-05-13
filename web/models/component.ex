defmodule Fulcrum.Component do
  use Fulcrum.Web, :model

  schema "components" do
    belongs_to :owner, Fulcrum.Owner
    field :name,          :string
    field :description,   :string
    field :version,       :string
    field :webpage,       :string
    field :metadata_url,  :string
    field :image_url,     :string
    field :start_command, :string
    field :discovery_url, :string
    field :config,        :string
    field :shareable,     :boolean
    field :installation_type, :string
    # stuff we generate to start this
    field :requires,      {:array, :string}
    # dependent components
    field :dependencies,  {:array, :string}
    # knobs that can be twisted
    field :configurables, {:array, :map}
    # things this component can generate/answer to
    field :provides,      {:array, :string}
    # things this component send to hub
    field :publishes,     {:array, :string}
    # Accompaniments and Accompaniment configuration
    field :accompaniments, {:array, :map}

    field :state, :string

    has_many :dependent_instances, Fulcrum.Instance, foreign_key: :required_by_id
    has_many :instances, Fulcrum.Instance, on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(owner_id name discovery_url image_url metadata_url config version state installation_type)
  @optional_fields ~w(description webpage dependencies provides publishes requires start_command configurables accompaniments)
  @interesting_fields ~w(name description version webpage metadata_url envs
    image_url start_command discovery_url dependencies provides publishes
    configurables requires accompaniments)

  @installation_reasons ~w(requested dependency)
  @valid_states ~w(missing_dependencies ready_to_launch launched stopped)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty)
  def changeset(model, %{"url" => url, "owner_id" => oid, "installation_type" => it}) do
    parms = Fulcrum.Component.Index.fetch_params!(url)
            |> Map.put_new("owner_id", oid)
            |> Map.put_new("installation_type", it)
    changeset(model, parms)
  end
  def changeset(model, params) do
    if is_map(params) && !Map.has_key?(params, "state") && !Map.has_key?(params, :state) do
      #params = %{params | "state" => "missing_dependencies"}
      params = params |> Map.put_new("state", "missing_dependencies")
    end
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:installation_type, @installation_reasons)
    |> validate_inclusion(:state, @valid_states)
  end

  def interesting_fields do
    @interesting_fields
  end

  def required_fields do
    @required_fields
  end

  def optional_fields do
    @optional_fields
  end
  
  def accompaniment_configuration(component, type) do
    Enum.find(component.accompaniments, fn(acc) -> acc["type"] == Atom.to_string(type) end)
  end

  def missing_components(definition = %Fulcrum.Component{}) do
    loaded_components = from(c in Fulcrum.Component, select: c.name) |> Fulcrum.Repo.all
    definition.dependencies -- loaded_components
  end
end
