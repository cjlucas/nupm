use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :nupm, NuPMWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :nupm, NuPM.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "nupm_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  migration_primary_key: [id: :uuid, type: :binary_id],
	migration_timestamps: [type: :utc_datetime]
