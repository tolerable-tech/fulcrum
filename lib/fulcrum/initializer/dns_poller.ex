defmodule Fulcrum.Initializer.DnsPoller do

  def is_available? do
    case HTTPoison.get(dns_check_url) do
      {:ok, %HTTPoison.Response{status_code: 200}} -> true
      {:error, err} -> false # this catches connection errors
      {:ok, _} -> false     # this catches all other success/400 codes. We send 200's
    end
  end

  def setup_poll do
    Task.async(fn ->
      sleep
      poll
    end)
  end

  def poll do
    if is_available? do
      Fulcrum.Initializer.dns_availability_confirmed
    else
      sleep
      poll
    end
  end

  defp dns_check_url do
    Fulcrum.Settings.self_url("http", path: ".validate-domain")
  end

  defp sleep(time \\ 3000) do
    :timer.sleep time
  end
end
