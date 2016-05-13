defmodule Fulcrum.Instance.Env do
  alias Fulcrum.Repo
  alias Fulcrum.Instance.Generate
  alias Fulcrum.Specifier

  import Ecto.Query, only: [from: 2]

  def elements(instance) do
    # configurables
    instance.component.configurables
  end

  #def prepare(instance, req_string) when is_binary(req_string)  do
    #prepare(instance, String.split(req_string, ":", parts: 3))
  #end

  def prepare(instance, spec = %{"generable" => "true"}) do
    specifier = specifier_for(spec, instance)
    |> ensure_value(spec)
    {spec["name"], specifier.value}
  end
  def prepare(instance, spec = %{"default" => value}) when not is_nil(value) do
    specifier = specifier_for(spec, instance)
    |> ensure_value(spec)
    {spec["name"], specifier.value}
  end
  def prepare(instance, spec) do
    case specifier_for(spec, instance) do
      specifier = %Specifier{id: id} when not is_nil(id) ->
        {spec["name"], specifier.value}
      _ ->
        :skip
    end
  end

  defp specifier_for(spec, instance) do
    query = from sp in Specifier, where: sp.name == ^spec["name"] and sp.instance_id == ^instance.id or sp.component_id == ^instance.component_id and sp.name == ^spec["name"]
    case Repo.all(query) do
      [specifier = %Specifier{}] ->
        specifier
      [specifier = %Specifier{}, ospecifier = %Specifier{}] ->
        if (specifier.instance_id != nil), do: specifier, else: ospecifier
      [] ->
        #%Specifier{type: type, name: name, instance_id: instance.id}
        %{Specifier.from_spec(spec) | instance_id: instance.id}
    end
  end

  defp ensure_value(specifier = %Specifier{value: nil}, %{"generable" => "true"}) do
    val = Generate.env(specifier.name)

    {:ok, specifier} = specifier
    |> Specifier.changeset(%{value: val, value_source: "generated"})
    |> persist
    specifier
  end
  defp ensure_value(specifier = %Specifier{value: nil}, %{"default" => value}) when not is_nil(value) do
    {:ok, specifier} = specifier
    |> Specifier.changeset(%{value: value, value_source: "defaulted"})
    |> persist
    specifier
  end
  defp ensure_value(specifier = %Specifier{}, _) do
    specifier
  end

  defp persist(rec = %Specifier{id: nil}) do
    changeset = Specifier.changeset(rec, :empty)
    Repo.insert(changeset)
  end
  defp persist(rec = %Ecto.Changeset{model: %{id: nil}}) do
    Repo.insert(rec)
  end
  defp persist(rec = %Ecto.Changeset{}) do
    Repo.update(rec)
  end
  #defp persist(rec = %Specifier{}) do
    #Repo.update(rec)
  #end

end
