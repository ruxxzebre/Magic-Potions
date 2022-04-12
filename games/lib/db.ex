defmodule Games.DB do
  @db_path "games.bin"

  def write(collection) do
    File.write!(@db_path, :erlang.term_to_binary(collection))
    collection # needed? TODO: check
  end

  def load_or_create do
    if File.exists?(@db_path) do
      :erlang.binary_to_term(File.read!(@db_path))
    else
      starting_value = []
      write(starting_value)
    end
  end
end