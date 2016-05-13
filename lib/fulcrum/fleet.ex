# A wrapper around FleetApi.Direct GenServer that uses names
defmodule Fulcrum.Fleet do
  @fleet FleetApi.Direct

  alias Fulcrum.Instance
  import Fulcrum.Component.Naming, only: [component_name: 1, unit_name: 1]

  def start_link(url) do
    GenServer.start_link(@fleet, url, name: @fleet)
  end

  def units do
    {:ok, units} = @fleet.list_units(@fleet)
    units
  end

  def put_unit(unit = %Instance.UnitFile{}) do
    put_unit(unit.name, Instance.UnitFile.to_fleet(unit))
  end
  def put_unit(name, unit = %FleetApi.Unit{}) do
    @fleet.set_unit(@fleet, name, unit)
  end

  def destroy_unit(name) do
    @fleet.delete_unit(@fleet, name)
  end

  def set_unit_state([], _state), do: :ok
  def set_unit_state([unit | rest], state) do
    set_unit_state(unit, state)
    set_unit_state(rest, state)
  end
  def set_unit_state(unit = %Instance.UnitFile{}, state) do
    set_unit_state(unit.name, state)
  end
  def set_unit_state(name, :launched) when is_binary(name) do
    unit = %FleetApi.Unit{desiredState: "launched", name: unit_name(name)}
    set_unit_state(unit)
  end
  def set_unit_state(name, :stopped) when is_binary(name) do
    unit = %FleetApi.Unit{desiredState: "stopped", name: unit_name(name)}
    set_unit_state(unit)
  end
  def set_unit_state(unit = %FleetApi.Unit{}) do
    @fleet.set_unit(@fleet, unit.name, unit)
  end

  def component_names do
    component_names(units)
  end

  def component_names(list) when is_list(list) do
    list |> Enum.map(fn(x) -> component_name(x) end)
  end
end
