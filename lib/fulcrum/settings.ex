defmodule Fulcrum.Settings do
  @index_base_url "https://s3.amazonaws.com/components.fulcrum.tech/specs/"
  @fleet_url_default "http://172.17.8.101:49153"

  import System, only: [get_env: 1]

  def coreos_private_ipv4 do
    get_env("COREOS_PRIVATE_IPV4")
  end

  def etcd_host do
    "#{coreos_private_ipv4}:2379"
  end

  def etcd_api_url(path \\ "") do
    "http://#{etcd_host}#{path}"
  end

  def self_url(scheme, path: path) do
    scheme <> "://" <> top_domain <> "/" <> path
  end

  def docker_url do
    "http://#{coreos_private_ipv4}:2375"
  end

  def top_domain do
    get_env("TOP_DOMAIN")
    |> remove_scheme
    |> remove_trailing_slash
  end

  def fleet_url do
    "http://#{coreos_private_ipv4}:49153"
  end

  def index_base_url do
    (get_env("FULCRUM_INDEX") || @index_base_url)
  end

  def owner_email do
    get_env("OWNER_EMAIL")
  end

  # [user, pass, db]
  def postgres_config do
   (System.get_env("FULCRUM_DB") || "whoops:no:password")
   |> String.split(":", parts: 3)
  end

  def s3_env_vars do
    %{"id" => get_env("AWS_ACCESS_KEY_ID"),
      "secret" => get_env("AWS_SECRET_ACCESS_KEY"),
      "region" => get_env("AWS_REGION")}
  end

  defp remove_scheme(d) do
    String.replace(d, ~r{http(s|)://}, "")
  end

  defp remove_trailing_slash(d)do
    String.replace(d, "/", "")
  end
end
