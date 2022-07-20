defmodule KVServer.Command do
  require Logger

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
      ["HELP"] -> {:ok, {:help}}
      ["QUIT"] -> {:ok, {:quit}}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given command.
  """
  def run(command, server_pid)

  def run({:create, bucket}, server_pid) do
    pid = KV.Registry.create(server_pid, bucket)
    Logger.info("Created bucket #{bucket} with pid #{inspect pid}");
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket, key}, server_pid) do
    lookup(bucket, fn pid ->
      case KV.Bucket.get(pid, key) do
        # nil -> {:ok, "NOT FOUND\r\n"}
        value -> {:ok, "#{value}\r\nOK\r\n"}
      end
    end, server_pid)
  end

  def run({:put, bucket, key, value}, server_pid) do
    lookup(bucket, fn pid ->
      KV.Bucket.put(pid, key, value)
      Logger.info("Put #{key} = #{value} in bucket #{bucket}")
      {:ok, "OK\r\n"}
    end, server_pid)
  end

  def run({:delete, bucket, key}, server_pid) do
    lookup(bucket, fn pid ->
      KV.Bucket.delete(pid, key)
      Logger.info("Deleted #{key} from bucket #{bucket}")
      {:ok, "OK\r\n"}
    end, server_pid)
  end

  def run({:help}, _server_pid) do
    commands = [
      "CREATE <bucket>",
      "GET <bucket> <key>",
      "PUT <bucket> <key> <value>",
      "DELETE <bucket> <key>",
      "HELP",
      "QUIT"
    ]
    msg = commands |> Enum.map(&("    " <> &1)) |> Enum.join("\r\n")
    {:ok, "COMMANDS:\r\n" <> msg <> "\r\nOK\r\n"}
  end

  def run({:quit}, _server_pid) do
    {:ok, :quit}
  end

  defp lookup(bucket, callback, server_pid) do
    case KV.Registry.lookup(server_pid, bucket) do
      {:ok, pid} -> callback.(pid)
      :error ->
        Logger.error("Bucket #{bucket} not found, or server pid/name #{server_pid} is invalid")
        {:error, :not_found}
    end
  end
end
