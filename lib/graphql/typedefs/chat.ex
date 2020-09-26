defmodule API.Graphql.Chat do
  use Absinthe.Schema.Notation

  alias API.Graphql.Resolvers.Chat
  require Logger;
  @desc "Chat"
  object :chat do
    field(:id, non_null(:id))
    field(:index, non_null(:string))
    field(:creator_id, non_null(:id))
    field(:members, non_null(list_of(:user)))
    field(:messages, list_of(:chat_message))
    field(:updated_at, :datetime)
    field(:inserted_at, :datetime)
  end

  @desc "Chat Message"
  object :chat_message do
    field(:id, non_null(:id))
    field(:chat_id, non_null(:id))
    field(:content, non_null(:string))
    field(:creator_id, non_null(:id))
    field(:updated_at, :datetime)
    field(:inserted_at, :datetime)
  end

  # start of chat subscriptions
  @desc "chat related subscriptions"
  object :chat_subscriptions do
    field :new_message, :chat_message do
      arg(:chat_index, non_null(:string))

      config(fn args, _context ->
        {:ok, topic: args.chat_index}
      end)

      trigger(:send_chat_message, topic: fn msg ->
          msg.chat_index
        end
      )
    end
  end

  # end of chat subscriptions

  # start of chat queries
  @desc "chat related queries"
  object :chat_queries do
    field :chat, type: :chat do
      arg(:id, non_null(:id))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&Chat.chat/3)
    end

    field :my_chats, type: list_of(:chat) do
      arg(:page, non_null(:integer))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&Chat.myChats/3)
    end
  end

  # end of chat queries

  # start of chat mutations
  @desc "chat related mutations"
  object :chat_mutations do
    field :create_chat, type: non_null(:chat) do
      arg(:creator_id, non_null(:id))
      arg(:member_ids, non_null(list_of(:id)))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&Chat.createChat/3)
    end

    field :send_chat_message, type: non_null(:chat_message) do
      arg(:content, non_null(:string))
      arg(:chat_id, non_null(:id))
      arg(:creator_id, non_null(:id))
      arg(:chat_index, non_null(:string))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&Chat.sendMessage/3)
    end

    field :add_chat_member, type: non_null(:chat) do
      arg(:chat_id, non_null(:id))
      arg(:member_id, non_null(:id))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&Chat.addMember/3)
    end

    field :get_chat_messages, type: list_of(:chat_message) do
      arg(:chat_id, non_null(:id))
      arg(:page, non_null(:integer))
      middleware(API.Graphql.AuthMiddleware)
      resolve(&Chat.getMessages/3)
    end
  end

  # end of chat mutations
end
