defmodule Games.Entities.Game do
  @enforce_keys [:name, :producer, :year]
  defstruct [:id, :name, :producer, :year]
end
