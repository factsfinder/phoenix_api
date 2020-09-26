defmodule API.PostLike do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  schema "post_likes" do
    field(:creator_id, :id)
    timestamps()

    belongs_to(:post, API.Post)
  end

  def changeset(post_like, args) do
    post_like |> cast(args, [:creator_id, :post_id])
  end
end
