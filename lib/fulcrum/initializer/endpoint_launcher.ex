# NOTE: maybe later. going plug route for now.
#defmodule Fulcrum.Initializer.EndpointLauncher do

  #import Supervisor.Spec, warn: false

  #@ep_name Fulcrum.Supervisor

  #def run(state, Fulcrum.Endpoint) do
    #stop_initializer_endpoint(state)
    #Supervisor.start_child(@ep_name, supervisor(Fulcrum.Endpoint, []))
  #end

  #def run(state, Fulcrum.Initializer.Endpoint) do
  #end

  #defp stop_initializer_endpoint(state = %{initializer_endpoint: ep}) do
    #case Supervisor.terminate_child(@ep_name, ep.worker_id) do
      #:ok ->
        #Supervisor.destroy_child(@ep_name, ep.child_id)
        #state
      #{:error, _what} -> state
    #end
  #end
  #defp stop_initializer_endpoint(_state), do: false
#end
