defmodule Fulcrum.Component.Deleter do
  alias Fulcrum.Component
  alias Fulcrum.Repo
  def call(component) do
    component = Repo.preload(component, :instances)
    component
    |> stop_instances
    |> remove_instances
    |> delete_component
  end

  defp stop_instances(component = %Component{instances: []}), do: component
  defp stop_instances(component = %Component{instances: [instance]}) do
    Fulcrum.Instance.Remover.call(instance)
    component
  end

  defp remove_instances(component = %Component{instances: []}), do: component
  defp remove_instances(component = %Component{instances: [instance]}) do
    remove_linked_instances(Repo.preload(instance, :linked_instances).linked_instances)
    Repo.delete!(instance)
    component
  end

  defp delete_component(component) do
    Repo.delete!(component)
  end

  defp remove_linked_instances([]), do: :ok
  defp remove_linked_instances([inst | rest]) do
    Repo.delete!(inst)
    remove_linked_instances(rest)
  end
end

