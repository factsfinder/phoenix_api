defmodule API.Repo.Migrations.Posts do
  use Ecto.Migration

  def change do
    create table("posts") do
      add(:content, :text, null: false)
      add(:creator_id, references(:users), null: false)
      add(:likes_count, :integer, default: 0)
      add(:comments_count, :integer, default: 0)
      timestamps(type: :timestamptz)
      add(:archived_at, :timestamptz, default: nil)
    end

    create table("post_comments") do
      add(:content, :string, null: false)
      add(:post_id, references(:posts), null: false)
      add(:creator_id, references(:users), null: false)
      timestamps(type: :timestamptz)
    end

    create table("post_likes") do
      add(:post_id, references(:posts), null: false)
      add(:creator_id, references(:users), null: false)
      timestamps(type: :timestamptz)
    end

  end
end
