defmodule Fulcrum.Instance.Generate do
  def env(name) do
    case name do
      ~r(USER) ->
        string(20)
      ~r(PASSWORD) ->
        string(40)
      ~r(DB) ->
        "#{name}-#{string(2)}"
      _ ->
        string(10)
    end
  end

  def string(length) do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end
end
