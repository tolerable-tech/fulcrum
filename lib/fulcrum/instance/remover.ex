defmodule Fulcrum.Instance.Remover do
  alias Fulcrum.Component
  alias Fulcrum.Instance
  alias Fulcrum.Repo
  alias Fulcrum.Fleet

  import Fulcrum.Query.Instance, only: [linked_instances: 1]
  import Fulcrum.Component.Naming, only: [unit_name: 1]

  def call(instance = %Instance{}) do
    Enum.each(linked_instances(instance), fn(ins) ->
      #Fleet.destroy_unit(ins.fleet_name)
      #set_states_to_stopped(ins)
      call(ins)
    end)

    Fleet.destroy_unit(instance.fleet_name)

    {instance, component} = set_states_to_stopped(instance)

    AccompanimentManager.Api.remove_all(instance)

    {:ok, component}
  end

  defp set_states_to_stopped(instance) do
    cs = Instance.changeset(instance, %{"desired_state" => "stopped"})
    Repo.update(cs)
    instance = Repo.preload(instance, :component)
    cs = Component.changeset(instance.component, %{"state" => "ready_to_launch"})
    {:ok, nins} = Repo.update(cs)
    {instance, nins}
  end
end
