defmodule Fulcrum.Repo.Migrations.AddStateToComponents do
  use Ecto.Migration

  def change do
    alter table(:components) do
      add :state, :string
      add :configurables, {:array, :map}
    end
  end
end
