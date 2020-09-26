defmodule API.Graphql.Post do
  use Absinthe.Schema.Notation

  alias API.Graphql.Resolvers.Post, as: PostResolver

  require Logger

  @desc "Post"
  object :post do
    field(:id, non_null(:id))
    field(:content, non_null(:string))
    field(:creator, non_null(:user))
    field(:recent_comments, list_of(:post_comment))
    field(:likes_count, non_null(:integer))
    field(:comments_count, non_null(:integer))
    field(:liked_by_me, :boolean)
    field(:updated_at, :datetime)
    field(:inserted_at, :datetime)
  end

  @desc "Post Comment"
  object :post_comment do
    field(:id, non_null(:id))
    field(:creator, non_null(:user))
    field(:content, non_null(:string))
    field(:post_id, non_null(:id))
    field(:updated_at, :datetime)
    field(:inserted_at, :datetime)
  end

  @desc "post related queries"
  object :post_queries do
    @desc "Get all posts"
    field :posts, type: non_null(list_of(:post)) do
      arg(:type, non_null(:string))
      arg(:page, non_null(:integer))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&PostResolver.getPosts/3)
    end

    @desc "get post comments"
    field :comments, type: non_null(list_of(:post_comment)) do
      arg(:post_id, non_null(:id))
      arg(:page, non_null(:integer))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&PostResolver.getPostComments/3)
    end
  end

  @desc "post related mutations"
  object :post_mutations do
    @desc "create a new post"
    field :create_post, type: :post do
      arg(:content, non_null(:string))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&PostResolver.createPost/3)
    end

    @desc "update post"
    field :update_post, type: :post do
      arg(:id, non_null(:id))
      arg(:content, :string)
      arg(:likes_count, :integer)
      middleware(API.Graphql.AuthMiddleware)
      resolve(&PostResolver.updatePost/3)
    end

    @desc "toggle post like"
    field :toggle_post_like, type: :boolean do
      arg(:post_id, non_null(:id))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&PostResolver.togglePostLike/3)
    end

    @desc "delete a post by id"
    field :delete_post, type: :boolean do
      arg(:id, non_null(:id))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&PostResolver.deletePost/3)
    end

    @desc "create a new comment"
    field :create_comment, type: :post_comment do
      arg(:post_id, non_null(:id))
      arg(:content, non_null(:string))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&PostResolver.createComment/3)
    end
  end

  @desc "post related subscriptions"
  object :post_subscriptions do
    field :post_added, :post do
      arg(:name, non_null(:string))

      config(fn args, _ ->
        {:ok, topic: args.name}
      end)
    end
  end
end
