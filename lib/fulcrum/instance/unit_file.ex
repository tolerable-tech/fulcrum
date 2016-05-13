# This models the Unit Files we generate for Components.
# As such, it is tailored for that, not for general Unit files.
defmodule Fulcrum.Instance.UnitFile do
  @name __MODULE__

  # NOTE: these are written in reverse order. Not sure it matters except for
  # readability
  @options [
    conflicts:         {"X-Fleet", "Conflicts"},
    stop:              {"Service", "ExecStop"},
    start_post:        {"Service", "ExecStartPost"},
    start:             {"Service", "ExecStart"},
    start_pre:         {"Service", "ExecStartPre"},
    env_file:          {"Service", "EnvironmentFile"},
    kill_mode:         {"Service", "KillMode"},
    timeout_start_sec: {"Service", "TimeoutStartSec"},
    start_after:       {"Unit", "After"},
    requires:          {"Unit", "Requires"},
    description:       {"Unit", "Description"},
  ]

  alias Fulcrum.Component
  alias Fulcrum.Instance.UnitFile.DockerCommand
  import Component.Naming, only: [unit_name: 1, unit_names: 2, unit_names: 1]

  defstruct name: nil, requires: [], start_after: [], timeout_start_sec: "0",
    kill_mode: "none", env_file: "/etc/environment", start_pre: [], start: "",
    start_post: [], stop: "", conflicts: [], description: "", docker_opts: %{}


  def default_for_component(nition = %Component{}) do
    %@name{
      name: unit_name(nition),
      description: description(nition),
      requires: dependencies_for(nition),
      start_after: after_services(nition),
      start_pre: start_pre(nition),
      start: start_service(nition),
      start_post: start_post(nition),
      stop: stop_service(nition),
      conflicts: service_conflicts(nition),
      docker_opts: docker_opts(nition)
    }
  end

  def to_fleet(uf = %Fulcrum.Instance.UnitFile{}) do
    fleet = %FleetApi.Unit{name: uf.name, desiredState: "inactive"}
    opts = Enum.reduce(@options, [], fn({attr, {section, name}}, acc) ->
      #IO.puts "[#{uf.name}]: adding opt: #{inspect Map.fetch!(uf, attr)}, inspect #{inspect dops}"
      add_options(section, name, Map.fetch!(uf, attr), acc, uf.docker_opts)
    end)
    %{fleet | options: opts}
  end

  defp add_options(_s, _n, [], acc, _dopts), do: acc
  defp add_options(section, name, [value | values], acc, dopts) do
    add_options(section, name, values, add_options(section, name, value, acc, dopts), dopts)
  end
  defp add_options(section, name, cmd = %DockerCommand{}, acc, dopts) do
    [%FleetApi.UnitOption{name: name, section: section,
        value: DockerCommand.build(cmd, dopts)} | acc]
  end
  defp add_options(section, name, value, acc, _dopts) do
    [%FleetApi.UnitOption{name: name, section: section, value: value} | acc]
  end

  defp description(nition = %Component{}) do
    "A Fulcrum Generated Unit File for the #{nition.name} component."
  end

  defp dependencies_for(_nition = %Component{}) do
    ["etcd2", "docker"] |> unit_names |> Enum.uniq
  end

  defp after_services(nition = %Component{}) do
    dependencies_for(nition)
  end

  defp start_pre(nition = %Component{}) do
    ["/usr/bin/cp /home/core/fulcrum/fulcrum /home/core/fulcrum/fulcrum-#{nition.name}"]
  end

  defp start_service(nition = %Component{}) do
    %DockerCommand{terminal: true, cmd: :run,
      docker_binary: "/home/core/fulcrum/fulcrum-#{nition.name}"}
  end

  defp start_post(nition = %Component{provides: provides}) do
    if "http" in provides do
      [%DockerCommand{terminal: true, cmd: :net_connect,
          docker_binary: "/home/core/fulcrum/fulcrum-#{nition.name}"}]
    else
      []
    end
  end

  defp stop_service(_nition = %Component{}) do
    %DockerCommand{cmd: :stop}
  end

  defp service_conflicts(_nition = %Component{}) do
    #["fulcrum.service"]
    []
  end

  defp docker_opts(nition = %Component{}) do
    %{
      container_name: nil,
      image_url: nition.image_url,
      image_name: docker_image_name(nition),
      start_cmd: nition.start_command,
      envs: %{run: [FULCRUM_HOST: true]},
      links: [],
      ports: docker_published_ports(nition),
    }
  end

  defp docker_image_name(nition = %Component{}) do
    if (String.contains?(nition.image_url, "http")) do
      "fulcrumc/#{nition.name}:#{nition.version}"
    else
      nition.image_url
    end
  end

  defp docker_published_ports(nition) do
    Enum.filter(nition.publishes, fn(str) -> String.match?(str, ~r/^PORT:/) end)
      |> Enum.map(fn(str) -> [_, port] = String.split(str, ~r/^PORT:/); port end)
  end

  #defp env_list(_nition = %Component{}) do
    #[FULCRUM_HOST: true]
  #end
end
