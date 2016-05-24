defmodule Fulcrum.Repo.Migrations.CreateOwner do
  use Ecto.Migration

  def change do
    create table(:owners) do
      add :username, :string
      add :email, :string
      add :encrypted_password, :string

      timestamps
    end

    create index(:owners, [:email], unique: true)

  end
end
