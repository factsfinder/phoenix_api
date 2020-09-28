defmodule API.Graphql.User do
  use Absinthe.Schema.Notation

  alias API.Graphql.Resolvers.User

  @desc "user"
  object :user do
    field(:id, non_null(:id))
    field(:email, non_null(:string))
    field(:password, :string)
    field(:name, non_null(:string))
    field(:avatar_url, :string)
    field(:updated_at, :datetime)
    field(:inserted_at, :datetime)
  end

  @desc "user with auth token"
  object :userWithToken do
    field(:user, non_null(:user))
    field(:token, non_null(:string))
  end

  # start of queries
  @desc "user related queries"
  object :user_queries do
    @desc "get logged in user"
    field :me, type: :user do
      middleware(API.Graphql.AuthMiddleware)
      resolve(&User.me/3)
    end

    # Todo: pagination
    @desc "Get all the users"
    field :users, type: non_null(list_of(:user)) do
      middleware(API.Graphql.AuthMiddleware)
      resolve(&User.users/3)
    end

    @desc "Get a user by id"
    field :user, type: :user do
      arg(:id, non_null(:id))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&User.user/3)
    end
  end

  # end of queries

  # start of mutations
  @desc "user related mutations"
  object :user_mutations do
    @desc "login"
    field :login, type: non_null(:userWithToken) do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&User.login/3)
    end

    @desc "signup"
    field :signup, type: non_null(:userWithToken) do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:name, non_null(:string))
      arg(:avatar, :upload)
      resolve(&User.signup/3)
    end

    @desc "update user"
    field :update_user, type: non_null(:user) do
      arg(:id, non_null(:id))
      arg(:email, :string)
      arg(:name, :string)
      arg(:avatar, :upload)
      middleware(API.Graphql.AuthMiddleware)
      resolve(&User.update/3)
    end
  end

  # end of mutations
end
