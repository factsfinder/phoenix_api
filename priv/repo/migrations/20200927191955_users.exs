defmodule API.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table("users") do
      add(:email, :string, null: false)
      add(:password, :string, null: false)
      add(:name, :string, null: false, size: 50)
      add(:avatar, :string)
      add(:type, :string, null: false)
      timestamps(type: :timestamptz)
      add(:archived_at, :timestamptz, default: nil)
    end

    create(unique_index("users", [:email]))
  end
end
