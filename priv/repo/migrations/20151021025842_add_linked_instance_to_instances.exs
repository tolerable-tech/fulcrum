defmodule Fulcrum.Repo.Migrations.AddLinkedInstanceToInstances do
  use Ecto.Migration

  def change do
    alter table(:instances) do
      add :linked_instance_id, references(:instances, on_delete: :delete_all)
    end
  end
end
