defmodule Fulcrum.Repo.Migrations.AddArtifacts do
  use Ecto.Migration

  def change do
    create table(:artifacts) do
      add :owner_id, references(:owners, on_delete: :delete_all)
      add :component_id, references(:components, on_delete: :delete_all)
      add :associated_instance_ids, {:array, :string}

      add :type, :string
      add :name, :string
      add :properties, :map

      timestamps
    end
  end
end
