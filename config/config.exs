# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :weather,
  ecto_repos: [Weather.Repo],
  station_refresh_interval: 900_000, #15 minutes
  reaper_interval: 1_800_000 #30 minute interval on autoreaper

# Configures the endpoint
config :weather, WeatherWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RYhUJxL1AxgNlkeBNmzu3r+SIDAC2yQ8R5iIq3lzIJNNv/VJTayCLS6PWm9A/+Lj",
  render_errors: [view: WeatherWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Weather.PubSub,
  live_view: [signing_salt: "V8kFu9GX"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# tailwind css
config :tailwind,
  version: "3.0.12",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets",__DIR__)
  ]

# Support timezone calcs
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
