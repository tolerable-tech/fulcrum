defmodule Fulcrum.Repo.Migrations.AddInstanceTables do
  use Ecto.Migration

  def change do
    create table(:goals) do
      add :owner_id,     references(:owners)
      add :name,         :string
      add :description, :string

      add :properties,      :map

      add :started_stamp,   :datetime

      add :due_date,        :datetime
      add :completed_stamp, :datetime

      timestamps
    end

    alter table(:components) do
      add :requires,  {:array, :string}
      add :start_command, :string
      remove :desired_fleet_status
      remove :assigned_fleet_name
    end

    create table(:instances) do
      add :owner_id,       references(:owners)
      add :component_id,   references(:components)
      add :required_by_id, references(:components)
      add :goal_id,        references(:goals)
      add :envs,          :map
      add :fleet_name,    :string
      add :container_name, :string
      add :desired_state, :string

      timestamps
    end
  end

end
