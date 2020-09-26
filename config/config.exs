# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :api,
  namespace: API,
  ecto_repos: [API.Repo]

# Configures the endpoint
config :api, API.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "P5+l8mwHTQ9z/eN0gtsrHNoDhNxXmlER5zJ9SQp9Ak0MFj7cmEX0hwYIbCdnWcHc",
  pubsub_server: API.PubSub,
  live_view: [signing_salt: "Y7hRAEjK"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :arc,
  storage: Arc.Storage.S3,
  bucket: {:system, "BACKBLAZE_S3_BUCKET"},
  version_timeout: 30_000

config :ex_aws,
  debug_requests: true,
  json_codec: Jason,
  access_key_id: {:system, "BACKBLAZE_ACCESS_KEY"},
  secret_access_key: {:system, "BACKBLAZE_SECRET_KEY"},
  region: "us-west-002"

config :ex_aws, :s3,
  scheme: "https://",
  host: "s3.us-west-002.backblazeb2.com",
  region: "us-west-002"
  
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
