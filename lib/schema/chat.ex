defmodule API.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  alias API.{Repo, User, ChatMembership, ChatMessage}

  @timestamps_opts [type: :utc_datetime]

  schema "chats" do
    field(:index, :string)
    field(:creator_id, :id)
    field(:member_ids, {:array, :map}, virtual: true)
    timestamps()

    has_many(:chat_messages, ChatMessage)
    has_many(:chat_memberships, ChatMembership)
  end

  def changeset(chat, args) do
    chat
    |> cast(args, [
      :index,
      :creator_id,
    ])
    |> validate_required([:index, :creator_id])
    |> validate_length(:member_ids, min: 2)
  end
end
