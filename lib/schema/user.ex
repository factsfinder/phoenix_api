defmodule API.User do
  use Ecto.Schema
  use Arc.Ecto.Schema

  import Ecto.Changeset

  alias Argon2

  alias API.{School, Post, PostComment, ChatMembership, Uploads.Image}

  @timestamps_opts [type: :utc_datetime]
  schema "users" do
    field(:email, :string)
    field(:password, :string)
    field(:name, :string)
    field(:avatar, Image.Type)
    timestamps()

    has_many(:posts, Post, foreign_key: :creator_id)
    has_many(:post_comments, PostComment, foreign_key: :creator_id)
    has_many(:chat_memberships, ChatMembership, foreign_key: :member_id)
  end

  def update_changeset(user, args) do
    user
    |> cast(args, [:id, :email, :name])
    |> cast_attachments(args, [:avatar])
    |> validate_required([:id])
    # Todo: need better email validation
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def signup_changeset(user, args) do
    user
    |> cast(args, [:email, :password, :name])
    |> cast_attachments(args, [:avatar])
    |> validate_required([:name, :email, :password])
    # Todo: need better email validation
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 5, max: 20)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        Ecto.Changeset.put_change(changeset, :password, Argon2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end

  def map_user_avatar_url(user) do
    if user.avatar do
      avatar_url = Image.url({user.avatar, user}, :thumb, signed: true)
      Map.merge(user, %{avatar_url: avatar_url})
    else
      user
    end
  end
end
