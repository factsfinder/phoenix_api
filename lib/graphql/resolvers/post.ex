defmodule API.Graphql.Resolvers.Post do
  require Logger
  alias API.{Repo, Post, PostComment, PostLike, User}

  import Ecto.Query
  import Ecto.Changeset

  def createPost(_, args, %{context: %{current_user: current_user}}) do
    args_with_creator_id = Map.merge(args, %{creator_id: current_user.id})
    case Post.changeset(%Post{}, args_with_creator_id) |> Repo.insert() do
      {:ok, new_post} ->
        {:ok,
         Map.merge(new_post, %{
           creator: current_user,
           recent_comments: [],
           liked_by_me: false
         })}

      {:error, _} ->
        {:error, "Error creating a new post"}
    end
  end

  def updatePost(_, args, %{context: %{current_user: current_user}}) do
    case Repo.get_by(Post, id: args.id, creator_id: current_user.id) do
      %Post{} ->
        case Post.changeset(%Post{}, args).change() |> Repo.update() do
          {:ok, post} -> {:ok, post}
          {:error, _} -> {:error, "error updating the post"}
        end
    end
  end

  def togglePostLike(_, args, %{context: %{current_user: current_user}}) do
    args_with_creator_id = Map.merge(args, %{creator_id: current_user.id})

    case Repo.get_by(PostLike, creator_id: current_user.id, post_id: args.post_id) do
      nil ->
        case Repo.insert(PostLike.changeset(%PostLike{}, args_with_creator_id)) do
          {:ok, _} ->
            case updateLikesCount(args.post_id, true) do
              {:ok, _} -> {:ok, true}
              {:error, _} -> {:error, "error liking the post"}
            end

          {:error, _} ->
            {:error, "error liking the post"}
        end

      post_like ->
        case Repo.delete(post_like) do
          {:ok, _} ->
            case updateLikesCount(args.post_id, false) do
              {:ok, _} -> {:ok, true}
              {:error, _} -> {:error, "error unliking the post"}
            end

          {:error, _} ->
            {:error, "error unliking the post"}
        end
    end
  end

  defp updateLikesCount(post_id, isInc) do
    post = Repo.get(Post, post_id)

    case post do
      nil ->
        {:error, "error updating post"}

      post ->
        new_likes_count = if isInc, do: post.likes_count + 1, else: post.likes_count - 1
        updated = Repo.update(change(post, likes_count: new_likes_count))

        case updated do
          {:ok, _} -> {:ok, true}
          {:error, _} -> {:error, "error updating the post likes count"}
        end
    end
  end

  def createComment(_, args, %{context: %{current_user: current_user}}) do
    args_with_creator_id = Map.merge(args, %{creator_id: current_user.id})

    case PostComment.changeset(%PostComment{}, args_with_creator_id) |> Repo.insert() do
      {:ok, new_comment} ->
        {:ok,
         Map.merge(new_comment, %{
           creator: current_user
         })}

      {:error, _} ->
        {:error, "error creating a new comment"}
    end
  end

  def getPosts(_, %{page: page, type: type}, %{
        context: %{current_user: current_user}
      }) do
    query =
      from(p in Post,
        left_join: u in User,
        on: p.creator_id == u.id,
        left_join: ps in PostLike,
        on: ps.post_id == p.id,
        where: p.posted_to == ^type and is_nil(p.archived_at),
        order_by: [desc: p.inserted_at],
        offset: 10 * (^page - 1),
        limit: 10,
        select_merge: %{creator: u, liked_by_me: ps.creator_id == ^current_user.id}
      )

    posts =
      Repo.all(query)
      |> Enum.map(fn post ->
        post_creator =
          if post.creator_id == current_user.id,
            do: current_user,
            else: User.map_user_avatar_url(post.creator)

        Map.merge(post, %{
          creator: post_creator,
          likes_count:
            Repo.one(from(s in PostLike, where: s.post_id == ^post.id, select: count(s.id))),
          comments_count:
            Repo.one(from(c in PostComment, where: c.post_id == ^post.id, select: count(c.id)))
        })
      end)

    {:ok, posts}
  end

  # for threaded comments in future, read this: https://hexdocs.pm/ecto/Ecto.Schema.html#has_many/3
  def getPostComments(_, %{post_id: post_id, page: page}, %{
        context: %{current_user: current_user}
      }) do
    query =
      from(c in PostComment,
        where: c.post_id == ^post_id,
        offset: 5 * (^page - 1),
        limit: 5
      )

    post_comments =
      Repo.all(query)
      |> Enum.map(fn comment ->
        creator =
          if comment.creator_id == current_user.id,
            do: current_user,
            else: User.map_user_avatar_url(Repo.get(User, comment.creator_id))

        Map.merge(comment, %{creator: creator})
      end)

    {:ok, post_comments}
  end

  def deletePost(_, %{id: id}, _) do
    from(p in Post,
      where: p.id == ^id
    )
    |> Repo.update_all(set: [archived_at: DateTime.utc_now()])

    {:ok, true}
  end
end
