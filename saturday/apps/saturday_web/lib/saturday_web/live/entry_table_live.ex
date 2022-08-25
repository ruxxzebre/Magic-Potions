defmodule SaturdayWeb.EntryTableLive do
  use SaturdayWeb, :live_view

  alias Saturday.Entries
  # alias Saturday.Entries.Entry

  def mount(_params, _session, socket) do
    if connected?(socket), do: Entries.subscribe()

    socket =
      socket
      |> assign(table_data: Entries.list_entries(:format_fields))

    {:ok, socket}
  end

  def update_table_data(socket) do
    IO.puts "UPDATED_TABLE_DATA"

    {:noreply, assign(
      socket,
      table_data: Entries.list_entries(:format_fields)
    )}
  end

  def handle_info({:new_entry_created, _entry}, socket), do: update_table_data(socket)

  def handle_info({:entry_deleted, _entry}, socket), do: update_table_data(socket)

  def handle_event("delete_entry", %{"id" => id}, socket) do
    id = String.to_integer(id)

    Entries.delete_entry(Entries.get_entry!(id))

    {:noreply, socket}
  end
end
