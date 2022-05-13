defmodule Servy.Wildthings do
  alias Servy.Bear

  @db_path Path.expand("../../db", __DIR__)

  @spec list_bears :: [%Bear{}]
  def list_bears do
    @db_path
    |> Path.join("bears.json")
    |> read_json
    |> Poison.decode!(as: %{"bears" => [%Bear{}]})
    |> Map.get("bears")
  end

  defp read_json(source) do
    case File.read(source) do
      {:ok, contents} ->
        contents

      {:error, reason} ->
        IO.inspect("Error reading #{source}: #{reason}")
        "[]"
    end
  end

  @spec get_bear(binary | integer) :: Bear
  # * "when is_something" - is guard
  def get_bear(id) when is_integer(id) do
    list_bears() |> Enum.find(fn b -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear
  end
end
