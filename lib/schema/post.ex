defmodule API.Post do
  use Ecto.Schema

  import Ecto.Changeset

  alias API.{User, PostLike, PostComment}

  @timestamps_opts [type: :utc_datetime]
  schema "posts" do
    field(:content, :string)
    field(:creator_id, :id)
    field(:likes_count, :integer, default: 0)
    field(:comments_count, :integer, default: 0)
    field(:creator, :map, virtual: true)
    field(:liked_by_me, :boolean, virtual: true)
    timestamps()
    field(:archived_at, :utc_datetime, default: nil)
    belongs_to(:user, User, define_field: false)
    has_many(:post_likes, PostLike)
    has_many(:post_comments, PostComment)
  end

  def changeset(post, args) do
    post
    |> cast(args, [:content, :creator_id, :likes_count, :comments_count])
    |> validate_required([:content, :creator_id])
    |> validate_length(:content, min: 1)
  end
end
