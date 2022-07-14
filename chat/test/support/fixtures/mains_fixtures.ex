defmodule Chat.MainsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chat.Mains` context.
  """

  @doc """
  Generate a main.
  """
  def main_fixture(attrs \\ %{}) do
    {:ok, main} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Chat.Mains.create_main()

    main
  end
end
