defmodule Servy.SensorServer do
  @name :sensor_server
  use GenServer

  defmodule State do
    defstruct sensor_data: %{},
              refresh_interval: :timer.seconds(5)
  end

  # Client interface

  def start do
    GenServer.start(__MODULE__, %State{}, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(interval) do
    GenServer.cast(@name, {:set_refresh_interval, interval})
  end

  # Server Callbacks

  def init(state) do
    initial_state = %{state | sensor_data: run_tasks_to_get_sensor_data()}
    schedule_refresh(initial_state.refresh_interval)
    {:ok, initial_state}
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  def handle_cast({:set_refresh_interval, interval}, state) do
    {:noreply, put_in(state.refresh_interval, interval)}
  end

  def handle_info(:refresh, state) do
    new_state = %{state | sensor_data: run_tasks_to_get_sensor_data()}
    IO.puts("Refreshing the cache #{inspect(state)}...")
    schedule_refresh(new_state.refresh_interval)
    {:noreply, new_state}
  end

  def handle_info(unexpected, state) do
    IO.puts("Can't touch this! #{inspect(unexpected)}")
    {:noreply, state}
  end

  defp schedule_refresh(time_in_ms) do
    Process.send_after(self(), :refresh, time_in_ms)
  end

  defp run_tasks_to_get_sensor_data do
    task = Task.async(fn -> %{x: 2, y: 9, z: 55} end)
    location = Task.await(task)

    snapshots =
      [
        "cam-1",
        "cam-2",
        "cam-3"
      ]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    %{snapshots: snapshots, location: location}
  end
end
