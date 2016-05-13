defmodule Fulcrum.Goal do
  use Fulcrum.Web, :model

  schema "goals" do
    belongs_to :owner, Fulcrum.Owner

    field :name,            :string
    field :description,     :string
    field :properties,      :map
    field :started_stamp,   Ecto.DateTime
    field :due_date,        Ecto.DateTime
    field :completed_stamp, Ecto.DateTime

    timestamps
  end
end
