defmodule API.Graphql.Resolvers.Chat do
  alias API.{Repo, Chat, ChatMembership, ChatMessage, User}
  import Ecto.Query

  require Logger

  def chat(_, args, _) do
    case Repo.get(Chat, args.id) do
      nil -> {:error, "error getting chat by id"}
      res -> {:ok, res}
    end
  end

  def myChats(_, args, %{context: %{current_user: current_user, loader: loader}}) do
    query =
      from(c in Chat,
        left_join: cm in ChatMembership,
        on: cm.member_id == ^current_user.id and cm.chat_id == c.id,
        limit: 10,
        offset: 10 * ^args.page
      )

    chats = Repo.all(query)

    # Todo: fix n+1 issue while fetching members
    chats =
      Enum.map(chats, fn c ->
        member_ids = String.split(c.index, "-")

        members =
          Enum.map(member_ids, fn id ->
            Repo.get(User, id)
          end)

        messages =
          Repo.all(
            from(cm in ChatMessage,
              where: cm.chat_id == ^c.id,
              order_by: [desc: cm.inserted_at],
              limit: 10
            )
          )

        Map.merge(c, %{members: members, messages: messages})
      end)

    {:ok, chats}
  end

  def classChats(_, _, _) do
  end

  def createChat(_, args, _) do
    creator_id_exists_in_member_ids =
      Enum.any?(args.member_ids, fn id ->
        id == args.creator_id
      end)

    if creator_id_exists_in_member_ids do
      index = Enum.uniq(args.member_ids) |> Enum.sort() |> Enum.join("-")
      existing_chat = Repo.get_by(Chat, index: index)

      if existing_chat do
        {:ok, existing_chat}
      else
        Repo.transaction(fn ->
          case(Chat.changeset(%Chat{}, Map.merge(args, %{index: index})) |> Repo.insert()) do
            {:ok, new_chat} ->
              Enum.each(args.member_ids, fn id ->
                ChatMembership.changeset(
                  %ChatMembership{},
                  %{chat_id: new_chat.id, member_id: id}
                )
                |> Repo.insert()
              end)

              mapped_chat =
                Map.merge(new_chat, %{
                  messages: [],
                  members:
                    Enum.map(args.member_ids, fn id ->
                      Repo.get(User, id)
                    end)
                })

              mapped_chat

            {:error, _} ->
              Repo.rollback("error creating a new chat")
          end
        end)
      end
    else
      {:error, "creator id should exist in member ids array"}
    end
  end

  def sendMessage(_, args, _) do
    case ChatMessage.changeset(%ChatMessage{}, args) |> Repo.insert() do
      {:ok, message} -> {:ok, Map.merge(message, %{chat_index: args.chat_index})}
      {:error, _} -> {:error, "error sending chat message"}
    end
  end

  def addMember(_, _, _) do
  end

  def getMessages(_, args, _) do
    query =
      from(m in ChatMessage,
        where: m.chat_id == ^args.chat_id,
        order_by: [desc: m.inserted_at],
        limit: 10,
        offset: 10 * ^args.page
      )

    messages = Repo.all(query)

    if messages do
      {:ok, messages}
    else
      {:error, "error fetching messages"}
    end
  end
end
