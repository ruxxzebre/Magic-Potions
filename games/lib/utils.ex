defmodule Games.Utils do
  defp calculate_last_id(collection) do
    if collection == [] do
      0
    else
      collection
      |> Enum.max_by(fn game -> game.id end)
      |> Map.get(:id)
    end
  end
end