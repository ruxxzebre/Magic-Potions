defmodule Saturday.Queue do
  @moduledoc """
  Generic server for processing entries by applicants one by one.
  """
  use GenServer
  alias Saturday.Entries

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    existing_entries = Entries.list_entries(:only_dates)

    {:ok, %{
      applied_entries: existing_entries
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
    broadcast(:applied_entries_updated)

    {:reply, {:ok}, state}
  end

  @impl true
  def handle_call(:get_applied_entries, _from, state) do
    {:reply, state.applied_entries, state}
  end

  @impl true
  def handle_cast(:casting, state) do
    {:noreply, state}
  end

  def apply_to_entry(date) do
    GenServer.call(__MODULE__, {:apply_to_entry, date})
  end

  def applied_entries() do
    GenServer.call(__MODULE__, :get_applied_entries)
  end

  @topic inspect(__MODULE__)

  def subscribe(topic_prefix \\ "") do
    Phoenix.PubSub.subscribe(Saturday.PubSub, @topic <> topic_prefix)
  end

  def broadcast(event) do
    Phoenix.PubSub.broadcast(Saturday.PubSub, @topic, event)
  end

  def broadcast(event, data) do
    Phoenix.PubSub.broadcast(Saturday.PubSub, @topic, {event, data})
  end

  def broadcast_w_prefix(event, topic_prefix) when is_binary(topic_prefix) do
    Phoenix.PubSub.broadcast(Saturday.PubSub, @topic <> topic_prefix, event)
  end

  def broadcast_w_prefix(event, data, topic_prefix) when is_binary(topic_prefix) do
    Phoenix.PubSub.broadcast(Saturday.PubSub, @topic <> topic_prefix, {event, data})
  end
end
