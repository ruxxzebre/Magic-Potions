defmodule Licorice.Sessionz do
  @behaviour Plug.Session.Store

  def init(opts) do
    max_age = Keyword.get(opts, :store_max_age, 3600)

    %{max_age: max_age}
  end

  def get(conn, cookie, _opts)
    when cookie == ""
    when cookie == nil do
      {nil, %{}}
  end
end

defmodule Licorice.SessionServer do
  use GenServer
  require Logger

  @name :session_server

  defmodule Session do
    defstruct expires_at: Date,
    token: "",
    max_age: 0
  end

  def start_link(_arg) do
    Logger.info("Starting the #{__MODULE__} service...")
    serv = GenServer.start_link(__MODULE__, %{}, name: @name)
    case serv do
      {:ok, _pid} ->
        Logger.info("#{__MODULE__} successfully started")
      {:error, reason} ->
        Logger.error("#{__MODULE__} starting failed with reason #{reason}")
    end
    serv
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:start_session, user_id}, _from, state) when is_binary(user_id) do
    case Map.get(state, user_id) do
      nil ->
        new_session = %Session{
          expires_at: Date.utc_today() |> Date.add(1),
          token: UUID.uuid4()
        }
        new_state = %{state | user_id => new_session}
        {:reply, {:ok, new_session}, new_state}
      _ ->
        {:reply, {:error, "Session already started..."}, state}
    end
  end

  def handle_call({:reload_session_by_use, user_id}, _from, state) when is_binary(user_id) do
    new_session = %Session{
      expires_at: Date.utc_today() |> Date.add(1),
      token: UUID.uuid4()
    }
    new_state = %{state | user_id => new_session}
    {:reply, {:ok, new_session}, new_state}
  end

  def handle_cast({:close_session_by_user_id, user_id}, _from, state) when is_binary(user_id) do
    new_state = Map.delete(state, user_id)
    {:noreply, new_state}
  end

  def handle_call({:get_session_by_user_id, user_id}, _from, state) do

  end
end
