defmodule Saturday.Queue do
  @moduledoc """
  Generic server for processing entries by applicants one by one.
  """
  use GenServer

  # TODO: init from DB
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    {:ok, %{
      applied_entries: []
    }}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:apply_to_entry, date}, from, state) do
    IO.inspect(from)
    state = Map.update!(state, :applied_entries, fn entries -> [date | entries] end)
    broadcast({}, :applied_entries_updated)

    {:reply, {:ok}, state}
  end

  @impl true
  def handle_call(:get_applied_entries, _from, state) do
    {:reply, state.applied_entries, state}
  end

  @impl true
  def handle_cast(:applied_entries_, state) do
    {:noreply, state}
  end

  def apply_to_entry(date) do
    GenServer.call(__MODULE__, {:apply_to_entry, date})
  end

  def applied_entries() do
    GenServer.call(__MODULE__, :get_applied_entries)
  end

  @topic inspect(__MODULE__)

  def subscribe() do
    Phoenix.PubSub.subscribe(Saturday.PubSub, @topic)
  end

  def broadcast(data, event) do
    Phoenix.PubSub.broadcast(Saturday.PubSub, @topic, {event, data})
  end
end
