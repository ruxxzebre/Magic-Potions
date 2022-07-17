defmodule KV.Registry.GenServerVariant do
  require Logger
  use GenServer

  # SERVER

  @impl true
  def init(:ok) do
    Logger.info("KV.Registry: init")
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    case Map.has_key?(names, name) do
      true ->
        {:noreply, {names, refs}}
      _ ->
        {:ok, bucket} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(bucket)
        refs = Map.put(refs, ref, name)
        names = Map.put(names, name, bucket)
        {:noreply, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    Logger.debug("KV.Registry: handle_info: DOWN: #{inspect ref}")
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")
    {:noreply, state}
  end

  # CLIENT

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists,
  `:error` otherwise.
  """
  @spec lookup(atom | pid, binary()) :: :ok
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Creates a new `bucket` and stores it in registry.
  """
  @spec create(atom | pid, binary()) :: :ok
  def create(server, name) do
    cond do
      is_pid(server) && !Process.alive?(server) -> :error
      is_atom(server) && Process.whereis(server) == nil -> :error
      true -> GenServer.cast(server, {:create, name})
    end
  end
end
