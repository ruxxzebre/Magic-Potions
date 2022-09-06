defmodule SaturdayWeb.EntryTableLive do
  use SaturdayWeb, :live_view

  alias Saturday.Entries

  def mount(_params, _session, socket) do
    if connected?(socket), do: Entries.subscribe()

    paginate_options = %{page: 1, per_page: 5}

    socket =
      socket
      # |> assign(table_data: Entries.list_entries(:format_fields))
      |> assign(table_data: Entries.list_entries([
        paginate: paginate_options,
        # sort: %{sort_by: :id}
      ]),
        paginate_options: paginate_options
      )

    require Logger
    Logger.warn("SOCKET: #{inspect socket.assigns}")
    {:ok, socket}
  end

  def handle_event("change-page", %{"id" => page}, socket) do
    page = String.to_integer(page || "1")

    paginate_options =
      socket.assigns.paginate_options
      |> Map.put(:page, page)

    socket =
      socket
      |> assign(table_data: Entries.list_entries([
        paginate: paginate_options,
      ]),
        paginate_options: paginate_options
      )
    {:noreply, socket}
  end

  def handle_params2(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")

    paginate_options = %{page: page, per_page: per_page}

    table_data = Entries.list_entries(paginate: paginate_options)
    # (ArgumentError) cannot invoke handle_params/3 on SaturdayWeb.EntryTableLive because it is not mounted nor accessed through the router live/3 macro

    socket =
      socket
      |> assign(options: paginate_options,
        table_data: table_data
      )

    {:noreply, socket}
  end

  def update_table_data(socket) do
    IO.puts "UPDATED_TABLE_DATA"

    {:noreply, assign(
      socket,
      table_data: Entries.list_entries(:format_fields)
    )}
  end

  def handle_info({:new_entry_created, _entry}, socket), do: update_table_data(socket)

  def handle_info({:entry_deleted, _entry}, socket) do
    require Logger
    Logger.info("ENTRY_TABLE_LIVE: entry_deleted")
    update_table_data(socket)
  end

  def handle_event("delete_entry", %{"id" => id}, socket) do
    id = String.to_integer(id)

    Entries.delete_entry(Entries.get_entry!(id))

    {:noreply, socket}
  end
end
