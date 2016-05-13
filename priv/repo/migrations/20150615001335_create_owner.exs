defmodule Fulcrum.Repo.Migrations.CreateOwner do
  use Ecto.Migration

  def change do
    create table(:owners) do
      add :username, :string
      add :email, :string
      add :hash, :string
      add :recovery_hash, :string

      timestamps
    end

    create index(:owners, [:email], unique: true)

  end
end
