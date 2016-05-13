defmodule Fulcrum.InstanceView do
  use Fulcrum.Web, :view

  def has_configurables?([]), do: false
  def has_configurables?(_), do: true

end
