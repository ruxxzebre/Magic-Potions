defmodule Saturday.TokenLimiting do
  @moduledoc """
  Generic server for processing entries by applicants one by one.
  """
  use GenServer

  use Saturday.SubBehaviour, topic: inspect(__MODULE__)

  @token_revocation_timeout :timer.minutes(5)

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    {:ok,
     %{
       applied_user_tokens: %{}
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
  def handle_call({:is_token_eligible, {token, resource}}, _from, state) do
    require Logger
    Logger.info("checking elibibility for token #{token} and resource #{resource}")
    Logger.info(state.applied_user_tokens)

    result =
      is_nil(
        Enum.find(Map.get(state.applied_user_tokens, resource, []), nil, &(&1.token == token))
      )

    {:reply, result, state}
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
  def handle_cast({:record_token, {token, resource}}, state) do
    alias Saturday.Datum
    require Logger

    if Enum.find([], false, &(&1.token == token)) do
      "User by `#{token}` token is already applied."
    end

    state =
      Map.update!(
        state,
        :applied_user_tokens,
        &Map.update(&1, resource, [], fn tokens ->
          token_map = %{
            token: token,
            resource: resource,
            created_at: Datum.now()
          }

          Process.send_after(
            self(),
            {:revoke_token, token_map, resource},
            @token_revocation_timeout
          )

          Logger.info("A new user token `#{token} is recorded.`")

          [token_map | tokens]
        end)
      )

    {:noreply, state}
  end

  @impl true
  def handle_info({:revoke_token, token_map, resource}, state) do
    require Logger

    Logger.warn("User token `#{token_map.token}` is expired.")

    state =
      Map.update!(
        state,
        :applied_user_tokens,
        &Map.update(&1, resource, [], fn tokens ->
          Enum.filter(tokens, fn t -> t.token != token_map.token end)
        end)
      )

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

  def record_token(token, resource) do
    _cast(:record_token, {token, resource})
  end

  def eligible?(token, resource) do
    _call(:is_token_eligible, {token, resource})
  end
end
