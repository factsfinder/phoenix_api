defmodule API.Graphql.Schema do
  use Absinthe.Schema
  use ApolloTracing

  import_types(Absinthe.Plug.Types)
  import_types(Absinthe.Type.Custom)

  import_types(API.Graphql.User)
  import_types(API.Graphql.Post)
  import_types(API.Graphql.Chat)

  query do
    import_fields(:user_queries)
    import_fields(:post_queries)
    import_fields(:chat_queries)
  end

  mutation do
    import_fields(:user_mutations)
    import_fields(:post_mutations)
    import_fields(:chat_mutations)
  end

  subscription do
    import_fields(:chat_subscriptions)
    import_fields(:post_subscriptions)
  end

  def plugins() do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
