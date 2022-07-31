defmodule SaturdayWeb.BookingLive do
  use SaturdayWeb, :live_view

  alias Saturday.Schedule
  alias Saturday.Queue

  def mount(_params, session, socket) do
    IO.inspect(session)
    if connected?(socket), do: Queue.subscribe()

    socket = assign_initials(socket)
    {:ok, socket}
  end

  def assign_initials(socket) do
    applied_entries = Queue.applied_entries()
    date_range = Schedule.get_range()
    filtered_range = Schedule.filter_range(date_range, "", applied_entries)

    socket |>
      assign(
        search_q: "", date_range: date_range, filtered_range: filtered_range,
        applied_entries: applied_entries,
        temporary_assigns: [filtered_range: []]
      )
  end

  def handle_event("update-query", %{"search-query" => q}, %{ assigns: assigns } = socket) do
    filtered_range =
      assigns.date_range
      |> Schedule.filter_range(q, assigns.applied_entries)

    socket = assign(socket, search_q: q, filtered_range: filtered_range)
    {:noreply, socket}
  end

  def handle_event("apply-to-entry", %{"datetime" => datetime}, socket) do
    Queue.apply_to_entry(datetime)

    {:noreply, socket}
  end

  def handle_info(:applied_entries_updated, %{assigns: assigns} = socket) do
    applied_entries = Queue.applied_entries()

    filtered_range =
      assigns.date_range
      |> Schedule.filter_range("", applied_entries)

    socket = assign(socket, filtered_range: filtered_range, applied_entries: applied_entries)
    {:noreply, socket}
  end
end
