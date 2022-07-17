defmodule Games do
  alias Games.Entities.Game
  alias Games.DB
  alias Games.Utils

  @spec all_games :: list(Game)
  def all_games, do: load_or_create()

  @spec add(%Game{id: nil}) :: list(Game)
  def add(%Game{id: nil} = game) do
    last_id = calculate_last_id(all_games())

    game_with_id = struct(game, %{id: last_id + 1})

    write([game_with_id | all_games()])
  end

  @spec get(number()) :: Game
  def get(id) do
    Enum.find(all_games(), fn game -> game.id == id end)
  end

  @spec update(number(), any) :: :ok
  def update(id, fields) do
    # TODO
    :ok
  end

  @spec delete(number()) :: :ok
  def delete(id) do
    write(Enum.filter(all_games(), fn game -> game.id != id end))
  end
end
