defmodule KV.Bucket do
  use Agent, restart: :temporary
  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, get_key(key))
  end

  @doc """
  Puts the `value` for given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, put_key(key, value))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key` if it exists in `bucket`.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, delete_key(key))
  end

  defp get_key(key), do: fn map -> Map.get(map, key) end
  defp put_key(key, value), do: fn map -> Map.put(map, key, value) end
  defp delete_key(key), do: fn map -> Map.pop(map, key) end
end


defmodule KV.Bucket.Gen do
  use GenServer

  @doc """
  Starts a new bucket.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call({:delete, key}, _from, state) do
    {value, state} = Map.pop(state, key)
    {:reply, value, state}
  end

  def handle_cast({:put, key, value}, state) do
    state = Map.put(state, key, value)
    {:noreply, state}
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    GenServer.call(bucket, {:get, key})
  end

  @doc """
  Puts the `value` for given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    GenServer.cast(bucket, {:put, key, value})
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key` if it exists in `bucket`.
  """
  def delete(bucket, key) do
    GenServer.call(bucket, {:delete, key})
  end
end
