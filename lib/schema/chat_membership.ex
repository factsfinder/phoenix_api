defmodule API.ChatMembership do
  use Ecto.Schema
  import Ecto.Changeset

  alias API.{User, Chat}

  @timestamps_opts [type: :utc_datetime]
  schema "chat_memberships" do
    timestamps()
    belongs_to(:user, User, foreign_key: :member_id)
    belongs_to(:chat, Chat)
  end

  def changeset(chat, args) do
    chat
    |> cast(args, [:chat_id, :member_id])
    |> validate_required([:chat_id, :member_id])
  end
end
