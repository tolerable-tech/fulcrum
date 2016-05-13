defmodule Fulcrum.Component.Naming do

  def unit_name(nition = %{}) do
    nition.name |> unit_name
  end
  def unit_name(name) when is_binary(name) do
    if String.contains?(name, ".service"), do: name, else: "#{name}.service"
  end

  def unit_names(list \\ [], out \\ [])
  def unit_names(nil, out), do: out |> List.flatten
  def unit_names([], out), do: out |> List.flatten
  def unit_names([head | tail], out) do
    unit_names(tail, [unit_name(head) | out])
  end

  def component_name(nition = %{}) do
    nition.name |> component_name
  end
  def component_name(name) when is_binary(name) do
    name |> String.split(".service") |> List.first
  end

end
