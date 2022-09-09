defmodule SaturdayWeb.ManagementLive do
  use SaturdayWeb, :live_view

  alias Saturday.Entries

  @fallback_key :agent_name
  @entry_schema [
    agent_name: [
      label: "ПІБ",
      string: "agent_name"
    ],
    agent_phone: [
      label: "Телефон",
      string: "agent_phone"
    ],
    misc: [
      label: "Пошта",
      string: "misc"
    ],
    booking_date: [
      label: "Зареєстровано на дату",
      string: "booking_date"
    ],
    inserted_at: [
      label: "Створено запис",
      string: "inserted_at"
    ]
  ]

  def init_params(socket, params) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "10")
    paginate_options = %{page: page, per_page: per_page}

    search_q = params["search_q"] || ""
    find_by =
      @entry_schema
      |> Enum.find({@fallback_key, []}, fn {_, list} ->
        Keyword.get(list, :string) == params["find_by"]
      end)
      |> elem(0)

    query = %{find_by: find_by, search_q: search_q }

    socket |> assign(paginate_options: paginate_options, query: query)
  end

  def init_assigns(socket) do
    socket
    |> assign(
      table_data: [],
      table_columns: @entry_schema,
      entry_amount: Entries.count_entries(),
      temporary_assigns: [table_data: []]
    )
  end

  def mount(params, _session, socket) do
    if connected?(socket), do: Entries.subscribe()

    socket =
      socket
      |> init_assigns()
      |> init_params(params)

    # socket =
    #   socket
    #   # |> assign(table_data: Entries.list_entries(:format_fields))
    #   |> assign(table_data: Entries.list_entries([
    #     paginate: paginate_options,
    #     # sort: %{sort_by: :id}
    #   ]),
    #     paginate_options: paginate_options
    #   )

    require Logger
    Logger.warn("SOCKET: #{inspect socket.assigns}")
    {:ok, socket}
  end

  def handle_event("change-page", %{"page" => page}, socket) do
    page = String.to_integer(page || "1")
    per_page = socket.assigns.paginate_options.per_page

    socket =
      socket
      |> push_patch(to: Routes.live_path(
        socket,
        __MODULE__,
        page: page,
        per_page: per_page
      ))

    {:noreply, socket}
  end

  def handle_params(params, _url, socket) do
    socket = init_params(socket, params)
    paginate_options = socket.assigns.paginate_options
    query = socket.assigns.query

    table_data = Entries.list_entries(
      paginate: paginate_options,
      # query: %{ find_by: :agent_name, search_q: "wefawef" }
      query: query
    )
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

  def handle_event("search-bar",
    %{"search_q" => search_q, "search_item" => search_item},
    socket) do
    require Logger
    Logger.info("SEARCH BAR UPDATED")

    search_q = cond do
      search_item in ["booking_date", "inserted_at"] ->
        search_q
        |> String.split("-")
        |> Enum.reverse()
        |> Enum.join(".")
      true -> search_q
    end

    socket =
      socket
      |> push_patch(to: Routes.live_path(
        socket,
        __MODULE__,
        (socket.assigns.paginate_options
        |> Enum.into([])) ++
        (
          socket.assigns.query
          |> Map.update!(:search_q, fn _ -> search_q end)
          |> Map.update!(:find_by, fn _ -> search_item end)
          |> Enum.into([])
        )
      ))

    {:noreply, socket}
  end
end
