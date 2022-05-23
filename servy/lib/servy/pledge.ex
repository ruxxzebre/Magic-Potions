defmodule Servy.PledgeServer do
  @name :pledge_server

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: [], time_passed: 0, stop: false
  end

  # Client Interface

  def callme(message) do
    GenServer.call(@name, message)
  end

  def start() do
    IO.puts("Starting the a #{@name} server...")
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def state(), do: GenServer.call(@name, :get_state)
  def job(), do: GenServer.cast(@name, {:set_interval, 1000, 0})
  def stop_job(), do: GenServer.cast(@name, :stop_interval)
  def blow(), do: send(@name, :total_shit)
  def create_pledge(name, amount), do: GenServer.call(@name, {:create_pledge, name, amount})
  def recent_pledges, do: GenServer.call(@name, :recent_pledges)
  def total_pledged, do: GenServer.call(@name, :total_pledged)
  def clear, do: GenServer.cast(@name, :clear)

  # Server callbacks

  def init(%State{} = state) do
    state = %{state | pledges: fetch_recent_pledges()}
    {:ok, state}
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_call(:total_pledged, _from, state),
    do: {:reply, Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum(), state}

  def handle_call(:recent_pledges, _from, state), do: {:reply, state.pledges, state}

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    {:reply, id, %{state | pledges: cached_pledges}}
  end

  def handle_cast({:set_interval, amount, idx}, %{stop: false} = state) do
    :timer.sleep(amount)
    IO.puts("Handling #{idx} for #{amount / 1000}s...")
    GenServer.cast(@name, {:set_interval, amount, idx + 1})
    {:noreply, %{state | time_passed: state.time_passed + amount / 1000}}
  end

  def handle_cast({:set_interval, _, _}, %{stop: true} = state) do
    IO.puts("Interval stopped")
    {:noreply, %{state | stop: false, time_passed: 0}}
  end

  def handle_cast(:stop_interval, state) do
    {:noreply, %{state | stop: true}}
  end

  def handle_cast({:set_cache_size, size}, state) when is_integer(size) do
    {:noreply, %{state | cache_size: size, pledges: state.pledges |> Enum.take(size)}}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_info(message, state) do
    IO.puts("Unexpected messaged: #{inspect(message)}")
    {:noreply, state}
  end

  def set_cache_size(size) do
    GenServer.cast(@name, {:set_cache_size, size})
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges() do
    [{"wilma", 15}, {"fred", 300}]
  end
end
