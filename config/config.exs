# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :summoner_watch_dog,
  ecto_repos: [SummonerWatchDog.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :summoner_watch_dog, SummonerWatchDog.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_foreign_key: [column: :id, type: :binary_id]

# Configures the endpoint
config :summoner_watch_dog, SummonerWatchDogWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: SummonerWatchDogWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SummonerWatchDog.PubSub,
  live_view: [signing_salt: "G0UepYZH"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [
    :request_id,
    # Riot API
    :riot_summoner_name,
    :riot_summoner_puuid,
    :riot_match_id,
    :riot_routing,
    :riot_region,
    :seraphine_error
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# RIOT API
config :seraphine, :riot_api_key, "RGAPI-***"

# Config last matches count for summoner to get 
config :summoner_watch_dog, SummonerWatchDog, matches_count: 5

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
