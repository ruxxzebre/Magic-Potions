defmodule Saturday.Queue do
  @moduledoc """
  Generic server for processing entries by applicants one by one.
  """
  use GenServer
  alias Saturday.Entries

  use Saturday.SubBehaviour, topic: inspect(__MODULE__)

  @token_revocation_timeout :timer.minutes(5)

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Entries.subscribe()
    existing_entries = Entries.list_entries(:only_dates)

    {:ok, %{
      applied_entries: existing_entries,
      applied_user_tokens: []
    }}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  defp _cast(payload_or_action) do
    GenServer.cast(__MODULE__, payload_or_action)
  end

  defp _cast(action, payload) do
    GenServer.cast(__MODULE__, {action, payload})
  end

  defp _call(payload_or_action) do
    GenServer.call(__MODULE__, payload_or_action)
  end

  defp _call(action, payload) do
    GenServer.call(__MODULE__, {action, payload})
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
  def handle_call({:is_token_eligible, token}, _from, state) do
    result =
      is_nil(Enum.find(state.applied_user_tokens, nil, &(&1.token == token)))

    {:reply, result, state}
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
    # * EXAMPLE
    {:noreply, state}
  end

  @impl true
  def handle_cast({:record_token_after_application, token}, state) do
    alias Saturday.Datum
    require Logger

    if Enum.find([], false, &(&1.token == token)) do
      "User by `#{token}` token is already applied."
    end

    state = Map.update!(state, :applied_user_tokens, fn tokens ->
      token_map = %{
        token: token,
        created_at: Datum.now()
      }

      Process.send_after(self(), {:revoke_token, token_map}, @token_revocation_timeout)

      Logger.info("A new user token `#{token} is recorded.`")

      [token_map | tokens]
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:revoke_token, token_map}, state) do
    require Logger

    Logger.warn("User token `#{token_map.token}` is expired.")

    state = Map.update!(state, :applied_user_tokens, fn tokens ->
      Enum.filter(tokens, fn t -> t.token != token_map.token end)
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:entry_deleted, {:ok, entry}}, state) do
    booking_date = entry.booking_date

    state =
      state
      |> Map.update!(:applied_entries, fn applied_entries ->
        Enum.filter(applied_entries, &(&1 != booking_date))
      end)

    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end

  def apply_to_entry(date) do
    _call(:apply_to_entry, date)
  end

  def applied_entries() do
    _call(:get_applied_entries)
  end

  def booked?(date) do
    _call(:booked?, date)
  end

  def record_token(token) do
    _cast(:record_token_after_application, token)
  end

  def eligible?(token) do
    _call(:is_token_eligible, token)
  end
end
