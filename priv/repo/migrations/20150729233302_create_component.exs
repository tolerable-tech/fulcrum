defmodule Fulcrum.Repo.Migrations.CreatePlugin do
  use Ecto.Migration

  def change do
    create table(:components) do
      add :owner_id, references(:owners)
      add :name, :string
      add :description,   :text
      add :version,       :string
      add :webpage,       :string
      add :metadata_url,  :string
      add :image_url,     :string
      add :discovery_url, :string
      add :access_url,    :string
      add :config,        :text
      add :installation_type, :string
      add :assigned_fleet_name, :string
      add :desired_fleet_status, :string
      add :dependencies,  {:array, :string}
      add :provides,      {:array, :string}
      add :publishes,     {:array, :string}

      timestamps
    end

  end
end
