defmodule KV.SepRegistry.Server do
  use GenServer

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  def handle_cast({:create, name}, names) do
    case Map.has_key?(names, name) do
      true ->
        {:noreply, names}
      _ ->
        {:ok, bucket} = KV.Bucket.start_link([])
        {:noreply, Map.put(names, name, bucket)}
    end
  end
end

defmodule KV.SepRegistry do
  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists,
  `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Creates a new `bucket` and stores it in registry.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end
end
