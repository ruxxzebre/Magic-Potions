defmodule Saturday.Schedule.MemStorage do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{range: Saturday.Schedule.get_range_obscure()}}
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
          Map.put(state, :range, Saturday.Schedule.get_range_obscure())
          # set_range()

        _ ->
          Logger.info("Range is cached. Retrieving...")
          state
      end

    {:reply, state.range, state}
  end

  def handle_info(:refresh_range, state) do
    require Logger
    Logger.info("Refetching range...")
    # set_range()
    new_state = Map.put(state, :range, Saturday.Schedule.get_range_obscure())
    schedule_refresh()
    {:noreply, new_state}
  end


  def set_range() do
    GenServer.call(__MODULE__, :set_range)
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh_range, :timer.minutes(60))
  end

  def get_range() do
    GenServer.call(__MODULE__, :get_range)
  end
end
