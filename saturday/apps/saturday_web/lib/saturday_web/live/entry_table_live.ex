defmodule SaturdayWeb.EntryTableLive do
  use SaturdayWeb, :live_view

  alias Saturday.Entries
  alias Saturday.Queue

  def mount(_params, _session, socket) do
    # ! TODO: not working
    if connected?(socket), do: Queue.subscribe()

    socket =
      socket
      |> assign(table_data: Entries.list_entries(:format_fields))

    {:ok, socket}
  end

  def handle_info(:applied_entries_updated, socket) do
    IO.inspect("__UPDATED__")

    socket =
      socket
      |> assign(table_data: Entries.list_entries(:format_fields))

    {:noreply, socket}
  end
end
