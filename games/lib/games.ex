defmodule Games do
  alias Games.Entities.Game

  @db_path "games.bin"

  @spec all_games :: list(Game)
  def all_games, do: load_or_create()

  @spec add(%Game{id: nil}) :: list(Game)
  def add(%Game{id: nil} = game) do
    last_id = calculate_last_id()

    game_with_id = struct(game, %{id: last_id + 1})

    new_list = [game_with_id | all_games()]
    File.write!(@db_path, :erlang.term_to_binary(new_list))
    new_list
  end

  @spec get(number()) :: Game
  def get(id) do
    Enum.find(all_games(), fn game -> game.id == id end)
  end

  @spec update(number(), any) :: :ok
  def update(id, fields) do
    write(Enum.filter(all_games(), fn game -> game.id != id end))
  end

  @spec delete(number()) :: :ok
  def delete(id) do
    write(Enum.filter(all_games(), fn game -> game.id != id end))
  end

  defp calculate_last_id do
    if all_games() == [] do
      0
    else
      all_games()
      |> Enum.max_by(fn game -> game.id end)
      |> Map.get(:id)
    end
   end

  defp write(collection) do
    File.write!(@db_path, :erlang.term_to_binary(collection))
  end

  defp load_or_create do
    if File.exists?(@db_path) do
      :erlang.binary_to_term(File.read!(@db_path))
    else
      starting_value = []
      write(starting_value)
    end
  end
end
