defmodule Fulcrum.Instance.UnitFile.DockerCommand do
  defstruct(docker_binary: "/usr/bin/docker", cmd: "run", terminal: false)

  def build(cmd = %__MODULE__{cmd: :run}, opts) do
    cmd.docker_binary <> " run #{container_name(opts.container_name)} " <>
      "#{opts.image_name} #{env_string(cmd.cmd, opts)} " <> link_string(opts) <>
      " #{ports_string(opts)}"
  end
  def build(cmd = %__MODULE__{cmd: :fetch_image}, opts) do
    if (String.contains?(opts.image_url, "http")) do
      %{cmd | cmd: :import} |> build(opts)
    else
      %{cmd | cmd: :pull} |> build(opts)
    end
  end
  def build(_cmd = %__MODULE__{cmd: :import}, opts) do
    cmd = "'CMD #{opts.start_cmd}'"
    curl_cmd = "/usr/bin/curl #{opts.image_url} | docker import --change" <>
      " #{cmd} - #{opts.image_name}"
    "/bin/bash -c \"#{curl_cmd}\""
  end
  def build(cmd = %__MODULE__{cmd: :pull}, opts) do
    terminal_prefix(cmd) <> cmd.docker_binary <> " pull " <> opts.image_url
  end
  def build(cmd = %__MODULE__{cmd: :net_connect}, opts) do
    nm = container_name(opts.container_name)
    connect_cmd = %__MODULE__{}.docker_binary <> " network connect fulcrum-nginx #{nm}"
    cmd.docker_binary <> " wait-then #{nm} #{connect_cmd}"
  end
  def build(cmd, opts) do
    [terminal_prefix(cmd) <> cmd.docker_binary, cmd.cmd, container_name(opts.container_name)]
      |> Enum.join(" ")
  end

  defp container_name(list) when is_list(list) do
    Enum.join(list, "_") <> "_c"
  end
  defp container_name(name) when is_binary(name), do: name

  defp env_string(:run, opts) do
    Enum.map(opts.envs.run, fn({name, value}) ->
      "#{name}=#{value}"
    end) |> Enum.join(",")
  end

  defp link_string(%{links: []}), do: "none"
  defp link_string(cmd) do
    Enum.map(cmd.links, fn({container, component}) -> 
      "#{container}:#{component}.fulcrum"
    end) |> Enum.join(",")
  end

  defp ports_string(opts = %{ports: []}), do: "none"
  defp ports_string(%{ports: ports})  do
    Enum.map(ports, fn(port) ->
      "::#{port}"
    end) |> Enum.join(",")
  end

  defp terminal_prefix(%{terminal: false}), do: "-"
  defp terminal_prefix(%{terminal: true}), do: ""
end
