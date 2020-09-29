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
    post = Repo.get_by(Post, id: args.id, creator_id: current_user.id)

    case Post.changeset(post, args).change() |> Repo.update() do
      {:ok, res} -> {:ok, res}
      {:error, _} -> {:error, "error updating the post"}
    end
  end

  def togglePostLike(_, args, %{context: %{current_user: current_user}}) do
    args_with_creator_id = Map.merge(args, %{creator_id: current_user.id})
    Repo.transaction(fn ->
      case Repo.get_by(PostLike, creator_id: current_user.id, post_id: args.post_id) do
        nil ->
          case Repo.insert(PostLike.changeset(%PostLike{}, args_with_creator_id)) do
            {:ok, _} ->
              case updateLikesCount(args.post_id, true) do
                {:ok, _} -> true
                {:error, _} ->
                  Repo.rollback("error updating post like -> rolling back.")
              end

            {:error, _} ->
              Repo.rollback("error updating post like -> rolling back.")
          end

        post_like ->
          case Repo.delete(post_like) do
            {:ok, _} ->
              case updateLikesCount(args.post_id, false) do
                {:ok, _} -> true
                {:error, _} ->
                  Repo.rollback("error updating post like -> rolling back.")
              end

            {:error, _} ->
              Repo.rollback("error updating post like -> rolling back.")
          end
      end
    end)

  end

  defp updateLikesCount(post_id, isInc) do
    post = Repo.get(Post, post_id)
    case post do
      nil ->
        {:error, "error updating post likes count"}
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
    Repo.transaction(fn ->
      case PostComment.changeset(%PostComment{}, args_with_creator_id) |> Repo.insert() do
        {:ok, new_comment} ->
          case updateCommentsCount(args.post_id, true) do
            {:ok, _} ->  Map.merge(new_comment, %{creator: current_user})
            {:error, _} ->  Repo.rollback("error updating comments count so rolling back created comment...!")
          end
        {:error, _} ->
          Repo.rollback("error creating a new comment -> rolling back.")
      end
    end)
  end

  # Note: isInc will be false when we are deleting a comment
  defp updateCommentsCount(post_id, isInc) do
    post = Repo.get(Post, post_id)
    case post do
      nil ->
        {:error, "error updating post comments count"}
      _ ->
        new_comments_count = if isInc, do: post.comments_count + 1, else: post.comments_count - 1
        updated = Repo.update(change(post, comments_count: new_comments_count))

        case updated do
          {:ok, _} -> {:ok, true}
          {:error, _} -> {:error, "error updating the post comments count"}
        end
    end
  end


  def getPosts(_, %{page: page, type: type}, %{
        context: %{current_user: current_user}
      }) do

    query =
      from(post in Post,
        join: post_creator in assoc(post, :user),
        left_join: likes in assoc(post, :post_likes),
        left_join: comments in assoc(post, :post_comments),
        left_join: comment_creator in assoc(comments, :user),
        preload: [user: post_creator, post_comments: {comments, user: comment_creator}],
        where: post.posted_to == ^type and is_nil(post.archived_at),
        order_by: [desc: post.inserted_at],
        offset: 10 * (^page - 1),
        limit: 10,
        select_merge: %{
          liked_by_me: likes.post_id == post.id and likes.creator_id == ^current_user.id
        }
      )

    posts =
      Repo.all(query)
      |> Enum.map(fn post ->
        post_creator =
          if post.creator_id == current_user.id,
            do: current_user,
            else: User.map_user_avatar_url(post.user)

        recent_comments =
          post.post_comments
          |> Enum.map(fn comment ->
            comment_creator =
              if comment.creator_id == current_user.id,
                do: current_user,
                else: User.map_user_avatar_url(comment.user)

            Map.merge(comment, %{
              creator: comment_creator
            })
          end)

        Map.merge(post, %{
          creator: post_creator,
          recent_comments: recent_comments
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
