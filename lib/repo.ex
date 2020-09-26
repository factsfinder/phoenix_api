defmodule API.Repo do
  use Ecto.Repo,
    otp_app: :api,
    adapter: Ecto.Adapters.Postgres,
    migration_timestamps: [type: :timestamptz]
end
