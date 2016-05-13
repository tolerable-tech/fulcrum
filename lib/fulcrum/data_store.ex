defmodule Fulcrum.DataStore do
  def querier do
    quote do
      alias Fulcrum.Repo
      alias Fulcrum.Query
      alias Fulcrum.DataStore
      alias Fulcrum.Component
      alias Fulcrum.Instance
      alias Fulcrum.Specifier
      import Ecto.Model
      import Ecto.Query, only: [from: 2]
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

defmodule Fulcrum.DataStore.Container do
  use Fulcrum.DataStore, :querier

  def instance_for(container_name, preload: preloads) do
    if Fulcrum.Initializer.up? do
      case Repo.get_by(Instance, container_name: container_name) do
        nil -> :unknown
        instance -> instance |> Repo.preload(preloads)
      end
    else
      :unknown
    end
  end
  def instance_for(container_name) do
    if Fulcrum.Initializer.up? do
      case Repo.get_by(Instance, container_name: container_name) do
        nil -> :unknown
        instance -> instance
      end
    else
      :unknown
    end
  end

  def hostnames_for(container_name) when is_binary(container_name) do
    instance_for(container_name) |> hostnames_for
  end
  def hostnames_for(ins = %Instance{}) do
    q = from sp in Query.Specifier.pertaining_to(ins, include_component: true),
      where: sp.export_as == ^"hostname",
      select: sp.value
    Repo.all(q)
  end

  def endpoint_for(container_name) when is_binary(container_name) do
    instance_for(container_name) |> endpoint_for
  end
  def endpoint_for(ins = %Instance{}) do
    q = from sp in Query.Specifier.pertaining_to(ins, include_component: true),
      where: sp.export_as == ^"location",
      select: sp.value
    case Repo.all(q) do
      [o] -> o
      [] -> nil
      ot -> hd ot
    end
  end

  def component_name_for(container_name) do
    q = from ins in Instance,
      where: ins.container_name == ^container_name,
      preload: [:component]
    i = Repo.one(q)
    i.component.name
  end
end

defmodule Fulcrum.DataStore.Instance do
  use Fulcrum.DataStore, :querier

  def accompaniment_configuration(instance, type) do
    Component.accompaniment_configuration(instance.component, type)
  end

  def migratable_linked_instance(instance, migratable \\ ["postgres"]) do
    instance = Repo.preload(instance, [linked_instances: [:component]])
    Enum.find(instance.linked_instances, fn(ins) ->
      ins.component.name in migratable
    end)
  end
end

defmodule Fulcrum.DataStore.Credentials do
  use Fulcrum.DataStore, :querier

  def available_for(:s3, %{main: acc_spec}), do: available_for(:s3, acc_spec)
  def available_for(:s3, acc_spec) do
    case Query.Specifier.for(:s3, %{id: acc_spec.owner_id}) do
      nil -> false
      _ -> true
    end
  end

  def for(:s3, %Instance{} = instance) do
    rec = Query.Specifier.for(:s3, instance.owner)
    %{id: rec.value_map["id"],
     secret: rec.value_map["secret"],
     region: rec.value_map["region"]}
  end
  def for(:s3, %AccompanimentManager.AccompanimentOptions{} = instance) do
    rec = Query.Specifier.for(:s3, %{id: instance.main.owner_id})
    %{id: rec.value_map["id"],
     secret: rec.value_map["secret"],
     region: rec.value_map["region"]}
  end
  def for(:s3, %{} = opts) do
    rec = Query.Specifier.for(:s3, opts)
    %{id: rec.value_map["id"],
     secret: rec.value_map["secret"],
     region: rec.value_map["region"]}
  end
end
