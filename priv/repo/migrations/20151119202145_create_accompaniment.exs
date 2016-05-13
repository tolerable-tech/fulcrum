defmodule Fulcrum.Repo.Migrations.CreateAccompaniment do
  use Ecto.Migration

  def change do
    create table(:accompaniments) do
      #add :owner_id, references(:owners, on_delete: :delete_all)
      add :name, :string

      timestamps
    end

    alter table(:components) do
      add :accompaniments, {:array, :map}
      add :shareable, :boolean, default: false
    end

  end
end
