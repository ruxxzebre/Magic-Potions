defmodule Licorice.UsersStore do
  use GenServer
  require Logger

  @name :store_users

  defmodule User do
    defstruct name: "",
    hashed_password: "",
    session: nil,
    id: nil
  end

  defmodule UserMap do
    @spec add_user(map, %User{}) :: {:ok, map, %User{}} | {:error, String.t()}
    def add_user(store, %User{} = user) do
      case store |> Enum.find(fn ({_id, u}) -> u.name == user.name end) do
        nil ->
          id = UUID.uuid4()
          user = put_in(user.id, id)
          {:ok, Map.put(store, id, user), user}
        _ ->
          {:error, "User with such username already exists"}
      end
    end

    @spec get_user(map, String.t()) :: {:error, String.t()} | {:ok, %User{}}
    def get_user(store, user_id) when is_binary(user_id) do
      case Map.get(store, user_id) do
        nil ->
          {:error, "User with id #{user_id} not found"}
        result -> {:ok, result}
      end
    end

    def get_user(_, _) do
      {:error, "Invalid user_id type. Should be binary."}
    end
  end

  defmodule State do
    defstruct users: %{}
  end

  def start_link(_arg) do
    Logger.info("Starting the #{__MODULE__} service...")
    serv = GenServer.start_link(__MODULE__, %State{}, name: @name)
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

  def handle_call({:get_user, user_id}, _from, state) do
    {
      :reply,
      state.users |> UserMap.get_user(user_id),
      state
    }
  end

  def handle_call(:get_all_users, _from, state) do
    {
      :reply,
      state.users,
      state
    }
  end

  def handle_call({:add_user, user}, _from, state) do
    case state.users |> UserMap.add_user(user) do
      {:ok, users, user} ->
        {:reply, {:ok, user.id}, %{state | users: users}}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def add_user(user), do: GenServer.call(@name, {:add_user, user})

  def get_user(user_id), do: GenServer.call(@name, {:get_user, user_id})

  def get_all_users, do: GenServer.call(@name, :get_all_users)
end
