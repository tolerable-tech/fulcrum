          # Accompaniments
          # TODO: have a generic backup component that mounts docker volumes and uploads
          #       them to S3/equivalent that we spin up for these.
defmodule Fulcrum.Instance.Launcher do
  alias Fulcrum.Component
  alias Fulcrum.Instance
  alias Fulcrum.Repo
  alias Fulcrum.Fleet
  alias Fulcrum.Query

  import Fulcrum.Query.Instance, only: [linked_instances: 1]

  #import Component.Naming, only: [unit_names: 1]
  #import Regex, only: [match?: 2]
  #import Ecto.Model, only: [assoc: 2]

  def call(instance = %Instance{}) do
    case instance |> preloaded |> prepare_env |> require_requirements do
      {:ok, instance} ->
        instance = instance
          |> launch_dependencies
          |> Instance.assign_fleet_name
          |> Instance.assign_container_name
        {:ok, instance} = Repo.update(instance)
        generate_fleet_files(instance)
        set_launched_desired_state(instance)
        set_component_launched_state(instance.component)
        launch_accompaniments(instance)
        {:ok, instance}
      response ->
        IO.puts "whoa, noped out somewhere: "
        IO.inspect response
        response
    end
  end

  def prepare_env(instance = %Instance{}) do
    IO.puts "shitting for shit #{instance.component.name} #{inspect Instance.Env.elements(instance)}"
    envs = Enum.reduce(Instance.Env.elements(instance), %{}, fn(requisite, out) ->
      IO.puts "preparing env for #{inspect requisite}"
       case Instance.Env.prepare(instance, requisite) do
         :skip ->
           out
         {key, value} ->
           Dict.put(out, key, value)
      end
    end)

    %{instance | envs: Map.merge(envs, instance.envs || %{})}
  end

  defp require_requirements(instance = %Instance{}) do
    case Enum.reject(instance.component.requires, fn(elem) -> instance.envs |> Map.has_key?(elem) end) do
      [] ->
        {:ok, instance}
      missing ->
        {:error, {:missing_requirements, missing, instance}}
    end
  end

  defp launch_dependencies(instance = %Instance{}) do
    component = preloaded(instance.component, [:dependent_instances, :owner])
    # if we have instance records, use them
    launched = Enum.map(linked_instances(instance), fn(dep_inst) ->
      dep_inst = preloaded(dep_inst)
      call(dep_inst)
      dep_inst.component.name
    end)
    # if we don't, create them.
    IO.inspect(launched)
    IO.inspect(component.dependencies)
    IO.inspect(component.dependencies -- launched)
    Enum.each(component.dependencies -- launched, fn(dep_name) ->
      IO.inspect "launching #{dep_name}"
      dep_comp = Repo.get_by(Component, name: dep_name, owner_id: component.owner_id)
      {:ok, dep_inst} = Instance.from_component(dep_comp)
                        |> Map.put(:required_by_id, component.id)
                        |> Map.put(:linked_instance_id, instance.id)
                        |> Repo.insert
      call(dep_inst)
    end)
    instance
  end

  defp generate_fleet_files(instance = %Instance{}) do
    instance.component
    |> Instance.UnitFile.default_for_component
    |> instance_overrides(instance)
    |> Fleet.put_unit
  end

  # set ENVs, set name (if is dependency)
  defp instance_overrides(unit, instance) do
    dops = put_in(unit.docker_opts, [:envs, :run], unit.docker_opts.envs.run ++ Map.to_list(instance.envs))
    dops = %{dops | links: dops.links ++ dependency_links(instance),
      container_name: instance.container_name}

    dependencies = instance_dependencies(unit, instance)

    %{unit | docker_opts: dops, name: instance.fleet_name, start_after: dependencies,
      requires: dependencies}
    #%{unit | start: start, name: instance.fleet_name,
       #requires: instance_dependencies(unit, instance)}
  end

  # This is how we share the ENV vars between dependent containers.
  defp dependency_links(instance) do
    Enum.reduce(linked_instances(instance), [], fn(inst, out) ->
      inst = preloaded(inst, :component)
      [{inst.container_name, inst.component.name} | out]
    end)
  end

  defp instance_dependencies(unit, instance) do
    unit.requires ++ Enum.map(linked_instances(instance), fn(ins) -> ins.fleet_name end)
      |> List.delete(instance.fleet_name)
  end

  defp set_launched_desired_state(instance = %Instance{}) do
    instance.fleet_name |> Fleet.set_unit_state(:launched)
  end

  defp set_component_launched_state(component = %Component{state: "launched"}), do: component
  defp set_component_launched_state(component = %Component{}) do
    changeset = Component.changeset(component, %{state: "launched"})
    {:ok, component} = Repo.update(changeset)
    component
  end

  defp launch_accompaniments(%Instance{component: %{accompaniments: []}}), do: :ok
  defp launch_accompaniments(instance) do
    AccompanimentManager.Api.launch_all(instance)
  end

  defp preloaded(rec, preloads \\ [:component, :owner, :dependency_of]) do
    Repo.preload(rec, preloads)
  end

end
