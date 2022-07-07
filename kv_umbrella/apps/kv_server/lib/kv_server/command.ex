defmodule KVServer.Command do

  # * The ~S prevents the \r\n characters from being converted to a carriage return
  # * and line feed until they are evaluated in the test.

  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> KVServer.Command.parse("CREATE shopping\r\n")
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse("CREATE       shopping              \r\n")
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse("PUT shopping milk 1\r\n")
      {:ok, {:put, "shopping", "milk", "1"}}

      iex> KVServer.Command.parse "GET shopping milk\r\n"
      {:ok, {:get, "shopping", "milk"}}

      iex> KVServer.Command.parse "DELETE shopping eggs\r\n"
      {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands or commands with the wrong number of
  arguments return an error:

      iex> KVServer.Command.parse "UNKNOWN shopping eggs\r\n"
      {:error, :unknown_command}

      iex> KVServer.Command.parse "GET shopping\r\n"
      {:error, :unknown_command}
  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given command.
  """
  def run(command, server_pid)

  def run({:create, bucket}, server_pid) do
    KV.Registry.create(server_pid, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket, key}, server_pid) do
    lookup(bucket, fn pid ->
      case KV.Bucket.get(pid, key) do
        # nil -> {:error, :key_not_found}
        value -> {:ok, "#{value}\r\nOK\r\n"}
      end
    end, server_pid)
  end

  def run({:put, bucket, key, value}, server_pid) do
    lookup(bucket, fn pid ->
      KV.Bucket.put(pid, key, value)
      {:ok, "OK\r\n"}
    end, server_pid)
  end

  def run({:delete, bucket, key}, server_pid) do
    lookup(bucket, fn pid ->
      KV.Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end, server_pid)
  end

  defp lookup(bucket, callback, server_pid) do
    case KV.Registry.lookup(server_pid, bucket) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
