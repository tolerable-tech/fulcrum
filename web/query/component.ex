defmodule Fulcrum.Query.Component do
  use Fulcrum.Web, :query

  def index(show_dependents: false, owner: owner) do
    q = from c in Component, where: c.owner_id == ^owner.id and c.installation_type == "requested"
    q |> Repo.all
  end

  def index(show_dependents: true, owner: owner) do
    q = from c in Component, where: c.owner_id == ^owner.id
    q |> Repo.all
  end

  def specifications_for(component) do
    Repo.all(Fulcrum.Specifier, component_id: component.id)
  end
end
