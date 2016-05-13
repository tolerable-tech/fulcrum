defmodule Plugs.Initializer do
  import Plug.Conn
  import Fulcrum.Router.Helpers

  def init(config), do: config

  def call(conn, _opts) do
    case Fulcrum.Initializer.status do
      :up ->
        conn
      _status ->
        conn
        |> has_valid_token_in_session
        |> redirect_to_initializer_route
    end
  end

  defp has_valid_token_in_session(conn) do
    fetch_session(conn)
    get_session(conn, :token)
    |> validate_session_token(conn)
  end

  defp validate_session_token(nil, conn), do: {:invalid, conn}
  defp validate_session_token(token, conn) do
    case Fulcrum.Initializer.validate(token) do
      :valid -> {:valid, conn}
      :invalid -> {:invalid, conn}
    end
  end

  defp redirect_to_initializer_route({:valid, conn}), do: conn
  defp redirect_to_initializer_route({:invalid, conn}) do
    conn
    |> put_resp_header("location", token_validator_path(conn,:index))
    |> send_resp(302, "")
    |> halt
  end
end

