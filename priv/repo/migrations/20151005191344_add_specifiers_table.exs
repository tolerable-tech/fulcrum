defmodule Fulcrum.Repo.Migrations.AddSpecifiersTable do
  use Ecto.Migration

  def change do
    create table(:specifiers) do
      add :instance_id, references(:instances, on_delete: :delete_all)
      add :component_id, references(:components, on_delete: :delete_all)

      add :type, :string
      add :name, :string
      add :value, :string
      add :value_map, :map

      timestamps
    end
  end
end
