defmodule Fulcrum.Repo.Migrations.AddExportAsToSpecifiableAndChangeConfigurablesToArrayOfMaps do
  use Ecto.Migration

  def change do
    # THIS did not work, so I just went back and changed where we did it
    # originally and nuked the world.
    #alter table(:components) do
      #modify :configurables, {:array, :map}
    #end

    alter table(:specifiers) do
      add :export_as,    :string
      add :default,      :string
      add :generable,    :boolean, default: false
      add :value_source, :string
    end
  end
end
