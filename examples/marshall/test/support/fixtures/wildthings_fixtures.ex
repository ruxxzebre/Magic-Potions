defmodule Marshall.WildthingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Marshall.Wildthings` context.
  """

  @doc """
  Generate a bear.
  """
  def bear_fixture(attrs \\ %{}) do
    {:ok, bear} =
      attrs
      |> Enum.into(%{
        hibernating: true,
        name: "some name",
        type: "some type"
      })
      |> Marshall.Wildthings.create_bear()

    bear
  end
end
