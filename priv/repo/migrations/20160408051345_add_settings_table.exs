defmodule Fulcrum.Repo.Migrations.AddSettingsTable do
  use Ecto.Migration

  def change do
    alter table(:specifiers) do
      add(:owner_id, references(:owners))
    end
    create index(:specifiers, [:owner_id])
  end

end
