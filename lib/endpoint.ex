defmodule API.Endpoint do
  use Phoenix.Endpoint, otp_app: :api
  use Absinthe.Phoenix.Endpoint

   # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_api_key",
    signing_salt: "mM70nmCq"
  ]

  
  socket("/socket", API.UserSocket,
    websocket: true,
    longpoll: false
  )

  # For pheonix live dashboard
  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :api)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)

  plug(Corsica,
    origins: "http://localhost:3000",
    log: [rejected: :error, invalid: :warn, accepted: :debug],
    # Todo: make sure this is safe. Doing it now to prevent cors error with preflight requests from frontend
    allow_headers: :all,
    allow_credentials: true
  )

  plug(API.Router)
end
