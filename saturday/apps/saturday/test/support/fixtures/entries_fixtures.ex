defmodule Saturday.EntriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Saturday.Entries` context.
  """

  @doc """
  Generate a entry.
  """
  def entry_fixture(attrs \\ %{}) do
    {:ok, entry} =
      attrs
      |> Enum.into(%{
        agent_name: "some agent_name",
        agent_phone: "some agent_phone",
        booking_date: ~D[2022-07-25],
        created_at: ~D[2022-07-25],
        misc: "some misc"
      })
      |> Saturday.Entries.create_entry()

    entry
  end
end
