defmodule Saturday.Queue do
  @moduledoc """
  Generic server for processing entries by applicants one by one.
  """
  use GenServer
  alias Saturday.Entries

  use Saturday.SubBehaviour, topic: inspect(__MODULE__)

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
  def handle_call({:apply_to_entry, map}, _from, state) do
    require Logger

    case Entries.create_entry(map) do
      {:error, _changeset} ->
        Logger.error("Error when creating a new entry.")
        # changeset.errors
        # example:
        # errors: [booking_date: {"can't be blank", [validation: :required]}],
        {:reply, {:error}, state}
      {:ok, entry} ->
        date = entry.booking_date
        state = Map.update!(state, :applied_entries, fn entries -> [date | entries] end)
        # broadcast({:applied_entries_updated, date})
        broadcast(:applied_entries_updated)
        {:reply, {:ok}, state}
    end
  end

  @impl true
  def handle_call({:apply_to_entry, date}, _from, state) when is_binary(date) do
    state = Map.update!(state, :applied_entries, fn entries -> [date | entries] end)
    broadcast(:applied_entries_updated)

    {:reply, {:ok}, state}
  end

  @impl true
  def handle_call({:booked?, date}, _from, state) when is_binary(date) do
    {:reply, Entries.booked?(date), state}
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

  def booked?(date) do
    GenServer.call(__MODULE__, {:booked?, date})
  end
end
