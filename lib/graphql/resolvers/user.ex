defmodule API.Graphql.Resolvers.User do
  alias Argon2
  alias API.{Repo, User, Guardian}

  def user(_, args, _) do
    user_by_id = Repo.get(User, args.id)

    if user_by_id do
      {:ok, User.map_user_avatar_url(user_by_id)}
    else
      {:error, "error finding user by id"}
    end
  end

  # Todo: paginate
  def users(_, _args, _) do
    all_users = Repo.all(User)
    {:ok, all_users}
  end

  def me(_, _, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  def update(_, args, _) do
    import Ecto.Changeset

    case Repo.get_by(User, id: args.id) do
      nil ->
        {:error, "cant find the user by id"}

      user ->
        case change(User.update_changeset(user, args)) |> Repo.update() do
          {:ok, user} ->
            {:ok, User.map_user_avatar_url(user)}

          {:error, _} ->
            {:error, "error updating user"}
        end
    end
  end

  def login(_parent, args, _context) do
    case Repo.get_by!(User, email: String.downcase(args.email)) do
      nil ->
        "no user account exists with that email"

      user ->
        if Argon2.check_pass(user, args.password, hash_key: :password) do
          {:ok, token, _full_claims} = Guardian.encode_and_sign(user)
          userWithToken = %{user: User.map_user_avatar_url(user), token: token}
          {:ok, userWithToken}
        else
          {:error, "invalid credentials"}
        end
    end
  end

  def signup(_root, args, _context) do
    new_user = User.signup_changeset(%User{}, args) |> Repo.insert!()
    {:ok, token, _full_claims} = Guardian.encode_and_sign(new_user)
    userWithToken = %{user: User.map_user_avatar_url(new_user), token: token}
    {:ok, userWithToken}
  end
end
