defmodule SaturdayWeb.BookingLive do
  alias ElixirSense.Log
  use SaturdayWeb, :live_view

  import SaturdayWeb.Gettext

  alias Saturday.Schedule
  alias Saturday.Queue
  alias Saturday.Entries
  alias Saturday.Schedule.MemStorage
  alias Phoenix.LiveView.JS

  require Logger

  def mount(_params, session, socket) do
    csrf = Map.get(session, "_csrf_token")

    Logger.info("BOOKING_LIVE: `#{csrf}` is connected. Eligibility: #{Queue.eligible?(csrf)}")

    if connected?(socket) do
      Entries.subscribe()
      Queue.subscribe()
    end

    socket =
      assign_initials(socket)
      |> assign(csrf: csrf)

    {:ok, socket}
  end

  def assign_initials(socket) do
    Logger.info("BOOKING_LIVE: Assigning initials...")

    send(self(), :fetch_entry_range)

    socket
    |> assign(
      search_q: "",
      date_range: [],
      temporary_assigns: [date_range: []],
      current_datetime: nil,
      show_cs_modal: false
    )
    |> start_loading()
  end

  def handle_event("show-cs-modal", _, socket) do
    socket =
      if Saturday.TokenLimiting.eligible?(socket.assigns.csrf, "check-submission") === false do
        socket
        |> put_flash(:error, "Ви вичерпали ліміт запитів. Спробуйте пізніше.")
      else
        assign(socket,
          show_cs_modal: true
        )
      end

    {:noreply, socket}
  end

  def handle_event("close-cs-modal", _, socket) do
    socket =
      assign(socket,
        show_cs_modal: false
      )

    {:noreply, socket}
  end

  def handle_event("date-selected", %{"date" => q}, socket) do
    Logger.info("BOOKING_LIVE: Date selected: #{q}")

    [day, month, year] =
      q
      |> String.split("/")

    # date = "#{date[2]}-#{date[0]}-#{date[1]}"
    date = "#{year}.#{month}.0#{day}"

    Logger.info("BOOKING_LIVE: Date selected2: #{date}")

    send(self(), {:fetch_entry_range, date})
    socket = assign(socket, search_date: date)
    {:noreply, socket}
    # socket =
    #   socket
    #   |> assign(current_datetime: q)
    #   |> push_patch(
    #     to:
    #       Routes.live_path(
    #         socket,
    #         SaturdayWeb.BookingLive,
    #         datetime: q
    #       )
    #   )

    # {:noreply, socket}
  end

  def handle_event("update-query", %{"search-query" => q}, socket) do
    send(self(), {:fetch_entry_range, q})
    socket = assign(socket, search_q: q)
    {:noreply, socket}
  end

  def handle_event("apply-to-entry", %{"datetime" => datetime}, socket) do
    {:noreply, socket}
  end

  def handle_event("close-modal", _, socket) do
    Logger.info("BOOKING_LIVE: Closing modal")

    socket =
      socket
      |> push_patch(
        to:
          Routes.live_path(
            socket,
            SaturdayWeb.BookingLive
          )
      )
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
          eligible = Queue.eligible?(socket.assigns.csrf)

          if valid? do
            if eligible do
              socket
              |> assign(current_datetime: datetime)
            else
              socket
              |> put_flash(:error, dgettext("booking", "already-booked-flash"))
              |> push_patch(
                to:
                  Routes.live_path(
                    socket,
                    SaturdayWeb.BookingLive
                  )
              )
            end
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

  def handle_info({:record_token, resource}, socket) do
    Saturday.TokenLimiting.record_token(socket.assigns.csrf, resource)
    {:noreply, socket}
  end

  def handle_info(:successfully_applied_to_entry, socket) do
    Queue.record_token(socket.assigns.csrf)

    {:noreply, socket}
  end

  def handle_info(:fetch_entry_range, socket) do
    Logger.info("BOOKING_LIVE: Fetching entry range")

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
    send(self(), :fetch_entry_range)

    {:noreply, socket}
  end

  def handle_info(msg, socket) do
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
    id={"date-entry-#{@date}"}
    class="m-1 power-sky"
    >
      <button class={"button is-info"}
      ><%= Schedule.format_time(@date) %></button>
    </div>
    """
  end
end
