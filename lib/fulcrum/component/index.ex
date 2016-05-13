defmodule Fulcrum.Component.Index do
  alias Fulcrum.Component
  #@base_url "http://components.fulcrum.xyz.s3.amazonaws.com/specs/"
  #@base_url "https://s3.amazonaws.com/components.fulcrum.xyz/"

  import Fulcrum.Settings, only: [index_base_url: 0]

  def find(name) do
    fetch("#{index_base_url}#{name}.json")
  end

  def find_params(name) do
    fetch_params("#{index_base_url}#{name}.json")
  end

  def fetch!(url) do
    {:ok, ins} = fetch(url)
    ins
  end

  def fetch(url) do
    case fetch_params(url) do
      {:ok, parms} ->
        {:ok, parms |> from_params}
      error ->
        {:error, error}
    end
  end

  def fetch_params!(url) do
    {:ok, parms} = fetch_params(url)
    parms
  end

  def fetch_params(url) do
    url = urlify(url)
    case HTTPoison.request(:get, url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> parms_from_http_potion_response}
      {:ok, %HTTPoison.Response{status_code: 404, body: body}} ->
        IO.puts "Not found :("
        {:error, {:not_found, body}}
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        {:error, {reason}}
    end
  end

  defp parms_from_http_potion_response(body) do
    body
    |> Poison.decode!
    |> Dict.take(Component.interesting_fields)
    |> Dict.put_new("config", body |> String.replace("\n", ""))
  end

  defp from_params(parms) do
    parms
    |> Enum.reduce(%Component{}, fn({k, v}, acc) ->
      Map.put(acc, String.to_atom(k), v)
    end)
  end

  defp urlify(url) do
    if url =~ ~r(^http) do
      url
    else
      url = if String.contains?(url, ".json"), do: url, else: "#{url}.json"
      "#{index_base_url}#{url}"
    end
  end
end
