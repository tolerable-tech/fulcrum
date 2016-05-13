use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fulcrum, Fulcrum.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :fulcrum, Fulcrum.Repo,
  adapter: Ecto.Adapters.Postgres,
  #username: "runner",
  #password: "semaphoredb",
  username: "docker",
  password: "dockerdevelopmentpassword",
  hostname: "pg.docker",
  database: "fulcrum_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1 # Use a single connection for transactional tests
