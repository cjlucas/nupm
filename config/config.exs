# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :nupm,
  namespace: NuPM,
  ecto_repos: [NuPM.Repo],
  generators: [binary_id: true],
  package_path: "./packages"

# Configures the endpoint
config :nupm, NuPMWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1OSglcFAJHq7qP4Yb32sCCCP4ZTtMI7fMBD3N5mrucOxVKp3dsyNlN/Fh7h0iMcw",
  render_errors: [view: NuPMWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: NuPM.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
