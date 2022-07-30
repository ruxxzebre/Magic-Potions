defmodule SaturdayWeb.BookingLive do
  use SaturdayWeb, :live_view

  alias Saturday.Schedule

  def mount(_params, session, socket) do
    # TODO: make use of session token
    IO.inspect(session)
    date_range = Schedule.get_range()

    socket = assign(
      socket, search_q: "", date_range: date_range, filtered_range: date_range,
      applied_entries: [],
      temporary_assigns: [filtered_range: []]
    )
    {:ok, socket}
  end

  def handle_event("update-query", %{"search-query" => q}, %{ assigns: assigns } = socket) do
    filtered_range =
      assigns.date_range
      |> Schedule.filter_range(q, assigns.applied_entries)

    socket = assign(socket, search_q: q, filtered_range: filtered_range)
    {:noreply, socket}
  end

  def handle_event("apply-to-entry", %{"datetime" => datetime}, %{assigns: assigns} = socket) do
    applied_entries = [datetime | assigns.applied_entries]

    filtered_range =
      assigns.date_range
      |> Schedule.filter_range("", applied_entries)

    socket = assign(socket, filtered_range: filtered_range, applied_entries: applied_entries)
    {:noreply, socket}
  end
end
