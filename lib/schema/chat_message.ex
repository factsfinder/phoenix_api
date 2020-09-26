defmodule API.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  alias API.{Chat, User}

  @timestamps_opts [type: :utc_datetime]

  schema "chat_messages" do
    field(:creator_id, :id)
    field(:content, :string)
    field(:chat_index, :string, virtual: true)
    timestamps()
    belongs_to(:chat, Chat)
    belongs_to(:user, User, define_field: false)
  end

  def changeset(message, args) do
    message
    |> cast(args, [:chat_id, :creator_id, :content])
    |> validate_required([:chat_id, :creator_id, :content])
    |> validate_length(:content, min: 1)
  end
end
