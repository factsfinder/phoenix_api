defmodule API.Graphql.Schema.Context do
  @behaviour Plug
  import Plug.Conn

  alias API.{Repo, User, Guardian, Graphql}

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      %{current_user: User.map_user_avatar_url(current_user), loader: Graphql.Data.loader()}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         user <- Repo.get(User, claims["sub"]) do
      case user do
        nil -> {:error, "error"}
        _ -> {:ok, user}
      end
    else
      _ -> {:error, "error"}
    end
  end
end
