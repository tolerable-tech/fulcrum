defmodule Fulcrum.Query.Instance do
  use Fulcrum.Web, :query

  def linked_instances(instance = %Instance{}) do
    q = from ins in Instance, where: ins.linked_instance_id == ^instance.id
    Repo.all q
  end
end
