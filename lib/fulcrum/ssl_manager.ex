defmodule Fulcrum.SslManager do
  import Fulcrum.Settings, only: [etcd_api_url: 1]

  def enable do
    put_key("le/enabled", "true")
    put_key("le/expiring?prevExist=false", "")
    put_key("le/others?prevExist=false", "")
    put_key("le/stage?prevExist=false", "")
    true
  end

  defp put_key(name, value) do
    etcd_api_url("/v2/keys/#{name}?value=#{value}")
    |> HTTPoison.put("value=#{value}")
  end
end
