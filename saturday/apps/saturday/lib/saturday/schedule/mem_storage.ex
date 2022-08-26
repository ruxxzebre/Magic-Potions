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

  def handle_call(:get_range, _from, state) do
    Logger.info("Fetching range...")

    state =
      case state.range do
        [] ->
          Logger.info("Cache is empty. Generating a new one...")
          Map.put(state, :range, Saturday.Schedule.get_range_obscure())

        _ ->
          Logger.info("Range is cached. Retrieving...")
          state
      end

    {:reply, state.range, state}
  end

  def get_range() do
    GenServer.call(__MODULE__, :get_range)
  end
end
