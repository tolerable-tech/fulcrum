defmodule Fulcrum.Mixfile do
  use Mix.Project

  @version "0.0.1"
  @image_name "tolerable/fulcrum:#{@version}"

  def project do
    [app: :fulcrum,
     version: @version,
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps(File.exists?("./edip_run"))]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Fulcrum, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
      :phoenix_ecto, :postgrex, :httpoison, :fleet_api, :addict, :nginx_registry,
      :accompaniment_manager, :inets]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps(true) do
    #IO.puts "edip deps!"
      [{:phoenix, "~> 1.1.0"},
       {:ecto, "~> 1.1.5"},
       {:phoenix_ecto, "~> 1.1"},
       {:postgrex, "~> 0.11.0"},
       {:addict, "~> 0.2.0"},
       {:phoenix_html, "~> 2.0"},
       {:phoenix_live_reload, "~> 1.0", only: :dev},
       {:cowboy, "~> 1.0"},
       #{:httpoison, "~> 0.7"}, # required from fleet_api
       {:fleet_api, "~> 0.0"},
       {:exrm, "~> 0.19"},
       {:edip, "~> 0.4"},
       {:fulcrum_agent, github: "tolerable-tech/fulcrum_agent"}
       # Maybe?
       #{:etcd, "~> 0.0"},
     ]
  end
  defp deps(_) do
    #IO.inspect System.get_env("EDIP_RUN")
      [{:phoenix, "~> 1.1.0"},
       {:ecto, "~> 1.1.5"},
       {:phoenix_ecto, "~> 1.1"},
       {:postgrex, "~> 0.11.0"},
       {:addict, "~> 0.2.0"},
       {:phoenix_html, "~> 2.0"},
       {:phoenix_live_reload, "~> 1.0", only: :dev},
       {:cowboy, "~> 1.0"},
       #{:httpoison, "~> 0.7"}, # required from fleet_api
       {:fleet_api, "~> 0.0"},
       {:exrm, "~> 0.19"},
       {:edip, "~> 0.4"},
       {:fulcrum_agent, github: "tolerable-tech/fulcrum_agent"}
       # Maybe?
       #{:etcd, "~> 0.0"},
     ]
  end

  defp aliases do
    ["push": &do_edip_push/1]
  end

  defp do_edip_push(wat) do
    #&prepare_for_edip/1, "edip", &reset_from_edip/1, &tag_and_push/1
    prepare_for_edip(wat)
    try do
      case Mix.shell.cmd("mix edip", env: [{"EDIP_RUN", "yup"}]) do
        0 -> tag_and_push(wat)
        status -> IO.puts "build command exited #{status}, not pushing."
      end
    rescue
      e -> reset_from_edip(wat) && raise e
    end
    reset_from_edip(wat)
  end

  defp prepare_for_edip(_) do
    IO.puts "setting up for edip push"
    File.rename("deps", "/tmp/deps.linux")
    File.rename("deps.mac", "deps")

    File.touch("./edip_run")

    #File.cp_r("../fulcrum_agent", "./fulcrum_agent")
    #File.cp_r("Users/jsw/workspace/elixir/ecto", "./ecto")
  end

  defp reset_from_edip(_) do
    IO.puts "cleaning up from edip push"
    File.rename("deps", "deps.mac")
    File.rename("/tmp/deps.linux", "deps")
    File.rm("./edip_run")
  end

  defp tag_and_push(_) do
    Mix.shell.cmd("docker tag --force local/fulcrum:latest #{@image_name}")
    Mix.shell.cmd("docker push #{@image_name}")
  end
end
