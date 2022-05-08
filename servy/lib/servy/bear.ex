defmodule Servy.Bear do
  @moduledoc """
  Bear entity
  """

  defstruct id: nil, name: "", type: "", hibernating: false
  alias Servy.Bear

  def new_bear(id, name, type, hibernating) do
    %Bear{id: id, name: name, type: type, hibernating: hibernating}
  end

  def new_bear(id, name, type) do
    %Bear{id: id, name: name, type: type}
  end

  def is_grizzly(bear), do: bear.type == "Grizzly"

  def order_asc_by_name(bear1, bear2), do: bear1.name <= bear2.name
end
