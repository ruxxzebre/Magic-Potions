defmodule SaturdayWeb.BookingLive do
  use SaturdayWeb, :live_view

  alias Saturday.Schedule
  alias Saturday.Queue
  alias Saturday.Schedule.MemStorage

  def mount(_params, session, socket) do
    IO.inspect(session)
    if connected?(socket), do: Queue.subscribe()

    socket = assign_initials(socket)
    {:ok, socket}
  end

  def assign_initials(socket) do
    applied_entries = Queue.applied_entries()
    date_range = MemStorage.get_range()
    filtered_range = Schedule.filter_range(date_range, "", applied_entries)

    socket |>
      assign(
        search_q: "",
        filtered_range: filtered_range,
        applied_entries: applied_entries,
        temporary_assigns: [filtered_range: []],
        current_datetime: nil
      )
  end

  def handle_event("update-query", %{"search-query" => q}, %{ assigns: assigns } = socket) do
    filtered_range =
      MemStorage.get_range()
      |> Schedule.filter_range(q, assigns.applied_entries)

    socket = assign(socket, search_q: q, filtered_range: filtered_range)
    {:noreply, socket}
  end

  def handle_event("apply-to-entry", %{"datetime" => datetime}, socket) do
    # Queue.apply_to_entry(datetime)
    {:noreply, socket}
  end

  def handle_event("close-modal", _, socket) do
    socket =
      push_patch(socket,
        to: Routes.live_path(
          socket,
          SaturdayWeb.BookingLive
        ))
    {:noreply, socket}
  end

  def handle_params(params, _url, socket) do
    datetime = Map.get(params, "datetime", "")

    socket = cond do
      Schedule.validate_spec_date(datetime) ->
        socket
        |> assign(current_datetime: datetime)
      datetime != "" ->
        socket
        |> push_patch(
          to: Routes.live_path(
            socket,
            SaturdayWeb.BookingLive
          )
        )
      true -> socket
    end

    {:noreply, socket}
  end

  def handle_info(:applied_entries_updated, socket) do
    applied_entries = Queue.applied_entries()

    filtered_range =
      MemStorage.get_range()
      |> Schedule.filter_range("", applied_entries)

    socket = assign(socket, filtered_range: filtered_range, applied_entries: applied_entries)
    {:noreply, socket}
  end

  def render_entry_button(assigns) do
    ~H"""
    <div
    data-target="create-entry-modal"
    _phx-click="apply-to-entry"
    _phx-value-datetime={Schedule.date_to_spec(@entry.date)}
    id={"date-entry-#{@entry.date}"}
    class="is-inline-block js-modal-trigger">
      <button class={"button #{if @entry.booked, do: "is-light", else: ""}"}
      disabled={@entry.booked}
      ><%= Schedule.format_time(@entry.date) %></button>
    </div>
    """
  end
end
