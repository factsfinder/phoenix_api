defmodule API.Guardian do
  use Guardian, otp_app: :api
  alias API.{Repo, User}

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def subject_for_token() do
    {:error, "Not authorized"}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    {:ok, Repo.get!(User, id)}
  rescue
    Ecto.NoResultsError -> {:error, "Not found"}
  end

  def resource_from_claims() do
    {:error, "Not authorized"}
  end
end
