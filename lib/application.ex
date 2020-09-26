defmodule API.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      API.Repo,
      # Start the Telemetry supervisor
      API.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: API.PubSub},
      # Start the Endpoint (http/https)
      API.Endpoint,
      {Absinthe.Subscription, API.Endpoint}
      # Start a worker by calling: API.Worker.start_link(arg)
      # {API.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: API.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    API.Endpoint.config_change(changed, removed)
    :ok
  end
end
