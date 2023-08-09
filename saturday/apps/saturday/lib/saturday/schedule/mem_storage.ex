defmodule Saturday.Schedule.MemStorage do
  require Logger
  alias Saturday.Datum

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # TODO: update range if it's outdated (e.g. after a few hours)
    {:ok, %{range: Saturday.Schedule.get_range(), last_updated: Datum.now()}}
  end

  def handle_call(:get_simplified_range, _from, state) do
    {:reply, state.range, state}
  end

  def handle_call(:set_range, _from, state) do
    {:reply, nil, state}
  end

  def handle_call(:get_range, _from, state) do
    Logger.info("Fetching range...")

    state =
      case state.range do
        [] ->
          Logger.info("Cache is empty. Generating a new one...")
          Map.put(state, :range, Saturday.Schedule.get_range())

        _ ->
          Logger.info("Range is cached. Retrieving...")
          state
      end

    {:reply, state.range, state}
  end

  def handle_cast(:force_refresh_range, state) do
    require Logger
    Logger.info("Forcing range refresh...")
    new_state = Map.put(state, :range, Saturday.Schedule.get_range())
    {:noreply, new_state}
  end

  def handle_info(:refresh_range, state) do
    require Logger
    Logger.info("Refetching range...")
    new_state = Map.put(state, :range, Saturday.Schedule.get_range())
    schedule_refresh()
    {:noreply, new_state}
  end

  def schedule_range_refresh() do
    require Logger
    Logger.info("Scheduling range refresh...")
    schedule_refresh()
  end

  def set_range() do
    GenServer.call(__MODULE__, :set_range)
  end

  def refresh_range() do
    GenServer.cast(__MODULE__, :force_refresh_range)
  end

  defp schedule_refresh() do
    require Logger
    # GenServer.(__MODULE__, :refresh_range)
    # TODO?: why :nonsunspend
    # Process.send(self(), :refresh_range, :nosuspend)
    Process.send_after(self(), :refresh_range, :timer.minutes(60))
  end

  def get_range() do
    GenServer.call(__MODULE__, :get_range)
  end

  def just_log() do
    require Logger
    Logger.info("MEM_STORAGE JUST_LOG")
  end

  def code_change(_old_vsn, state) do
    require Logger
    Logger.info("MEM_STORAGE CODE-CHANGE")
    state = Map.put(state, :range, Saturday.Schedule.get_range())
    {:ok, state}
  end
end
