defmodule Fulcrum.ComponentView do
  use Fulcrum.Web, :view
  alias Fulcrum.Component
  alias Fulcrum.Query
  alias Fulcrum.Repo
  #import Plug.CSRFProtection, only: [get_csrf_token: 0]

  def dependency_list(nent) do
    if Enum.empty?(nent.dependencies) do
      "none"
    else
      Enum.join(nent.dependencies, ", ")
    end
  end

  def next_state(%Component{state: "stopped"}), do: "launched"
  def next_state(%Component{state: "ready_to_launch"}), do: "launched"
  def next_state(%Component{state: "missing_dependencies"}), do: "ready_to_launch"
  def next_state(%Component{state: "launched"}), do: "stopped"
  def next_state(_), do: "ready_to_launch"

  def verb_of_state(%Component{state: "launched"}), do: "Stop"
  def verb_of_state(%Component{state: "stopped"}), do: "Launch"
  def verb_of_state(%Component{state: "ready_to_launch"}), do: "Launch"
  def verb_of_state(%Component{state: "missing_dependencies"}), do: "Install Dependencies"
  def verb_of_state(_), do: "Install Dependencies"

  def has_configurables?(%Component{configurables: []}), do: false
  def has_configurables?(%Component{}), do: true

  def has_instances?(comp = %Component{instances: %Ecto.Association.NotLoaded{}}) do
    Repo.preload(comp, :instances) |> has_instances?
  end
  def has_instances?(comp = %Component{instances: instances}), do: !Enum.empty?(instances)

  def instances(comp = %Component{instances: %Ecto.Association.NotLoaded{}}) do
    Repo.preload(comp, :instances) |> instances
  end
  def instances(comp = %Component{instances: instances}), do: instances
end
