defmodule API.Router do
  use API, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug(API.Graphql.Schema.Context)
  end

  # Todo: Add authentication for livedashboard
  import Phoenix.LiveDashboard.Router

  scope "/dashboard" do
    pipe_through([:fetch_session, :protect_from_forgery, :api])
    live_dashboard("/", metrics: API.Telemetry)
  end

  scope "/" do
    pipe_through([:api])

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: API.Graphql.Schema,
      socket: API.UserSocket,
      pipeline: {ApolloTracing.Pipeline, :plug},
      interface: :playground
    )

    forward("/api/v1", Absinthe.Plug, schema: API.Graphql.Schema)
  end
end
