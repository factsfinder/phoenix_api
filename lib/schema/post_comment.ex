defmodule API.PostComment do
  use Ecto.Schema

  import Ecto.Changeset

  alias API.{User, Post}
  @timestamps_opts [type: :utc_datetime]
  schema "post_comments" do
    field(:content, :string)
    timestamps()

    belongs_to(:post, Post)
    belongs_to(:user, User, foreign_key: :creator_id)
  end

  def changeset(comment, args) do
    comment
    |> cast(args, [:content, :creator_id, :post_id])
    |> validate_required([:content, :creator_id, :post_id])
    |> validate_length(:content, min: 1)
  end
end
