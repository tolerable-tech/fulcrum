defmodule Fulcrum.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      # Alias the data repository and import query/model functions
      alias Fulcrum.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

      # Import URL helpers from the router
      import Fulcrum.Router.Helpers

      # The default endpoint for testing
      @endpoint Fulcrum.Endpoint
      @default_opts [
        store: :cookie,
        key: "foobar",
        encryption_salt: "encrypted cookie salt",
        signing_salt: "signing salt"
      ]
      @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))
      @secret String.duplicate("abcdef0123456789", 8)
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Fulcrum.Repo, [])
    end

    :ok
  end
end
