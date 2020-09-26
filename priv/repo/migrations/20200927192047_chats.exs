defmodule API.Repo.Migrations.Chats do
  use Ecto.Migration

  def change do
    create table("chats") do
      add(:index, :string, null: false)
      add(:creator_id, references(:users), null: false)
      add(:class_id, references(:classes))
      timestamps(type: :timestamptz)
      add(:archived_at, :timestamptz, default: nil)
    end

    create(unique_index("chats", [:index]))

    create table("chat_messages") do
      add(:content, :text, null: false)
      add(:chat_id, references(:chats), null: false)
      add(:creator_id, references(:users), null: false)
      add(:media, :text)
      timestamps(type: :timestamptz)
    end

    create table("chat_memberships") do
      add(:chat_id, references(:chats), null: false)
      add(:member_id, references(:users), null: false)
      # pending, accepted, declined
      add(:status, :string, null: false, default: "accepted")
      timestamps(type: :timestamptz)
    end
  end
end
