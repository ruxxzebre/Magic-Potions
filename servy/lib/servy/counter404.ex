defmodule Servy.C404Counter do
  use GenServer

  @name :nf_routes_counter

  def start, do: GenServer.start(__MODULE__, %{}, name: @name)
  def start_link(_arg) do
    IO.puts("Starting the 404 counter service...")
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get, path}, _from, state) do
    {:reply, Map.get(state, path, 0), state}
  end

  def handle_call(:get_all, _from, state), do: {:reply, state, state}

  def handle_cast({:bump, path}, state) do
    {:noreply, Map.update(state, path, 1, &(&1 + 1))}
  end

  def handle_cast(:reset, _state), do: {:noreply, %{}}

  def bump_count(path), do: GenServer.cast(@name, {:bump, path})
  def get_count(path), do: GenServer.call(@name, {:get, path})
  def get_counts(), do: GenServer.call(@name, :get_all)
end
