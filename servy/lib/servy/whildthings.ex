defmodule Servy.Wildthings do
  alias Servy.Bear

  @spec list_bears :: [%Bear{}]
  def list_bears do
    [
      Bear.new_bear(1, "Teddy", "Brown", true),
      Bear.new_bear(2, "Smokey", "Black"),
      Bear.new_bear(3, "Paddington", "Brown"),
      Bear.new_bear(4, "Scarface", "Grizzly", true),
      Bear.new_bear(5, "Snow", "Polar"),
      Bear.new_bear(6, "Brutus", "Grizzly")
    ]
  end

  @spec get_bear(binary | integer) :: Bear
  # * "when is_something" - is guard
  def get_bear(id) when is_integer(id) do
    list_bears() |> Enum.find(fn (b) -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer |> get_bear
  end
end
