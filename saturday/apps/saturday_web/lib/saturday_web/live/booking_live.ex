defmodule SaturdayWeb.BookingLive do
  use SaturdayWeb, :live_view

  alias Saturday.Schedule

  def mount(_params, _session, socket) do
    date_range = Schedule.get_range()

    socket = assign(socket, search_q: "", date_range: date_range, filtered_range: date_range)
    {:ok, socket}
  end

  def handle_event("update-query", %{"search-query" => q}, %{ assigns: assigns } = socket) do
    filtered_range = assigns.date_range |> Schedule.filter_range(q)

    socket = assign(socket, search_q: q, filtered_range: filtered_range)
    {:noreply, socket}
  end
end
