defmodule Fulcrum.Query.Specifier do
  use Fulcrum.Web, :query

  def pertaining_to(rec = %Component{}) do
    qe = from sp in Specifier, where: sp.component_id == ^rec.id
    Repo.all(qe)
  end
  def pertaining_to(rec, [pad_empties: true]) do
    pertaining_to(rec) |> padded_with_empties(rec)
  end
  def pertaining_to(rec, [pad_empties: false]) do
    pertaining_to(rec)
  end
  def pertaining_to(rec = %Instance{}, include_component: true) do
    qe = from sp in Specifier, where: sp.instance_id == ^rec.id or sp.component_id == ^rec.component_id
    qe
  end
  def pertaining_to(rec = %Instance{}) do
    qe = from sp in Specifier, where: sp.instance_id == ^rec.id
    Repo.all(qe)
  end

  def for(:s3, %{id: id} = _owner) do
    qe = from sp in Specifier, where: sp.owner_id == ^id and sp.name == ^"s3-credentials", limit: 1
    case Repo.all(qe) do
      [rec] -> rec
      _ -> %Specifier{}
    end
  end

  defp padded_with_empties(specifiers, comp = %Component{}) do
    padded_with_empties({:component_id, comp.id}, specifiers, comp.configurables)
  end
  defp padded_with_empties(specifiers, ins = %Instance{}) do
    ins = Repo.preload(ins, :component)
    padded_with_empties({:instance_id, ins.id}, specifiers, ins.component.configurables)
  end
  defp padded_with_empties({pertinent_key, pertinent_id}, specifiers, possibilities) do
    Enum.map(possibilities, fn(conf = %{"name" => conf_name}) ->
      case Enum.find(specifiers, fn(sp) -> sp.name == conf_name end) do
        nil ->
          %Fulcrum.Specifier{type: conf["type"], name: conf_name,
            export_as: conf["export_as"], generable: to_bool(conf["generable"])}
          |> Map.put(pertinent_key, pertinent_id)
        specifier ->
          #List.delete(specifiers, specifier)
          specifier
      end
    end)
  end

  defp to_bool("false"), do: false
  defp to_bool(false), do: false
  defp to_bool(), do: false
  defp to_bool(_), do: false
  defp to_bool("true"), do: true
  defp to_bool(true), do: true

end
