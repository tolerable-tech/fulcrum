defmodule Fulcrum.Specifier do
  use Fulcrum.Web, :model
  #import Fulcrum.Repo, only: [all: 3]
  alias Fulcrum.Repo
  alias Fulcrum.Query
  import Ecto.Model, only: [assoc: 2]
  import Ecto.Query, only: [from: 2]

  require Fulcrum.Instance

  schema "specifiers" do
    belongs_to :instance, Fulcrum.Instance
    belongs_to :component, Fulcrum.Component
    belongs_to :owner, Fulcrum.Owner

    field :type, :string          # data class (only string)
    field :name, :string
    field :value, :string
    field :value_map, :map

    field :export_as,    :string     # map this specifier to a value fulcrum knows about
    field :default,      :string
    field :generable,    :boolean    # can we generate this if nil
    field :value_source, :string # did we generated this or get it from the user

    timestamps
  end

  @required_fields ~w(type name value_source generable)
  @optional_fields ~w(value value_map export_as generable)
  @valid_types ~w(string)
  @valid_value_sources ~w(defaulted generated owner_input empty)

  #def specify!(instance = %Fulcrum.Instance{}, name, value) when is_binary(value) do
    #%Fulcrum.Specifier{instance_id: instance.id, type: "configured", name: name, value: value}
    #|> Repo.insert
  #end
  #def specify!(instance = %Fulcrum.Component{}, name, value) when is_binary(value) do
    #%Fulcrum.Specifier{component_id: instance.id, type: "configured", name: name, value: value}
    #|> Repo.insert
  #end

  def from_spec(spec = %{"name" => name}) do
    %__MODULE__{type: (spec["type"] || "string"), name: name, export_as: spec["export_as"],
      generable: to_bool(spec["generable"])}
  end
  def from_spec(spec = %{name: name}) do
    %__MODULE__{type: (spec.type || "string"), name: name, export_as: spec.export_as,
      generable: to_bool(spec.generable)}
  end

  def merge_for(pertaining_to, specifiers) do
    specifier_recs = Query.Specifier.pertaining_to(pertaining_to, pad_empties: true)
    Enum.reduce(specifier_recs, %{errors: []}, fn(conf, out) ->
      cond do
        Map.get(specifiers, conf.name) == nil && conf.id != nil ->
          Repo.delete(conf) |> note_errors(out)
        conf.value != Map.get(specifiers, conf.name) && conf.id == nil ->
          conf = %{conf | value: Map.get(specifiers, conf.name),
            value_source: "owner_input"}
          Repo.insert(conf) |> note_errors(out)
        conf.value != Map.get(specifiers, conf.name) ->
          cs = changeset(conf, %{value: Map.get(specifiers, conf.name),
            value_source: "owner_input"})
          Repo.update(cs) |> note_errors(out)
        true ->
          out
      end
    end)
  end

  def changeset(model, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:type, @valid_types)
    |> is_not_alone
  end

  def environment(ins = %Fulcrum.Instance{}) do
    from(s in assoc(ins, :specifiers), where: s.type == "environment") |> Repo.all
  end

  def generated(ins = %Fulcrum.Instance{}) do
    from(s in assoc(ins, :specifiers), where: s.type == "generated") |> Repo.all
  end

  def configured(ins = %Fulcrum.Instance{}) do
    from(s in assoc(ins, :specifiers), where: s.type == "configured") |> Repo.all
  end

  defp is_not_alone(cs = %Ecto.Changeset{model: %{component_id: nil, instance_id: nil}}) do
    %{cs | errors: cs.errors ++ [lonely: "must have either an instance_id or a component_id"]}
  end
  defp is_not_alone(cs), do: cs

  defp note_errors({:ok, rec}, out), do: out
  defp note_errors({:error, rec}, out), do: %{out | errors: out.errors ++ [rec]}

  defp to_bool("false"), do: false
  defp to_bool(false), do: false
  defp to_bool(nil), do: false
  defp to_bool(""), do: false
  defp to_bool, do: false
  defp to_bool("true"), do: true
  defp to_bool(true), do: true
end
