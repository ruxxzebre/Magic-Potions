defmodule SaturdayWeb.BookingLive do
  use SaturdayWeb, :live_view

  alias Saturday.Schedule
  alias Saturday.Queue
  alias Saturday.Entries
  alias Saturday.Schedule.MemStorage

  def mount(_params, session, socket) do
    IO.inspect(session)
    if connected?(socket) do
      Entries.subscribe()
      Queue.subscribe()
    end

    socket = assign_initials(socket)
    {:ok, socket}
  end

  def assign_initials(socket) do
    send(self(), :fetch_entry_range)

    socket
    |> assign(
      search_q: "",
      date_range: [],
      temporary_assigns: [date_range: []],
      current_datetime: nil
    )
    |> start_loading()
  end

  def handle_event("update-query", %{"search-query" => q}, socket) do
    send(self(), {:fetch_entry_range, q})

    socket = assign(socket, search_q: q)
    # {:noreply, start_loading(socket)}
    {:noreply, socket}
  end

  def handle_event("apply-to-entry", %{"datetime" => datetime}, socket) do
    # Queue.apply_to_entry(datetime)
    {:noreply, socket}
  end

  def handle_event("close-modal", _, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            SaturdayWeb.BookingLive
          )
      )

    socket =
      socket
      |> assign(current_datetime: "")

    {:noreply, socket}
  end

  def handle_params(params, _url, socket) do
    datetime = Map.get(params, "datetime", "")

    socket =
      cond do
        Schedule.validate_spec_date(datetime) ->
          specked_date = Schedule.date_from_spec(datetime, true)
          ruleset = Saturday.ConfigStorage.get_data(:ruleset)
          valid? = Schedule.RuleSet.validate_date_against_ruleset(ruleset, specked_date)

          if valid? do
            socket
            |> assign(current_datetime: datetime)
          else
            socket
            |> push_patch(
              to:
                Routes.live_path(
                  socket,
                  SaturdayWeb.BookingLive
                )
            )
          end

        datetime != "" ->
          socket
          |> push_patch(
            to:
              Routes.live_path(
                socket,
                SaturdayWeb.BookingLive
              )
          )

        true ->
          socket
      end

    {:noreply, socket}
  end

  def handle_info(:close_modal, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            SaturdayWeb.BookingLive
          )
      )

    {:noreply, socket}
  end

  def handle_info(:fetch_entry_range, socket) do
    date_range =
      MemStorage.get_range()
      |> Schedule.filter_range("", Queue.applied_entries())

    socket = assign(socket, date_range: date_range)

    {:noreply, stop_loading(socket)}
  end

  def handle_info({:fetch_entry_range, query}, socket) do
    date_range =
      MemStorage.get_range()
      |> Schedule.filter_range(query, Queue.applied_entries())

    socket = assign(socket, date_range: date_range)

    {:noreply, stop_loading(socket)}
  end

  def handle_info(:applied_entries_updated, socket) do
    send(self(), :fetch_entry_range)

    {:noreply, start_loading(socket)}
  end

  def handle_info({:entry_deleted, entry}, socket) do
    # TODO
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    require Logger
    Logger.warn("Invalid message handled in booking_live: #{inspect(msg)}")
    {:noreply, socket}
  end

  def start_loading(socket), do: set_loading(socket, true)
  def stop_loading(socket), do: set_loading(socket, false)

  def set_loading(socket, is_loading) do
    socket
    |> assign(loading: is_loading)
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
