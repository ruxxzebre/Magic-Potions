defmodule KV.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based on the `bucket`.
  """
  def route(bucket, mod, fun, args, table \\ Application.fetch_env!(:kv, :routing_table)) do
    IO.inspect("TABLO")
    IO.inspect(table)

    entry = get_entry(bucket, table)

    if elem(entry, 1) == node() do
      apply(mod, fun, args)
    else
      {KV.RouterTasks, elem(entry, 1)}
      |> Task.Supervisor.async(
        KV.Router,
        :route,
        [bucket, mod, fun, args]
      )
      |> Task.await()
    end
  end

  def no_entry_error(bucket, table) do
    raise "could not find entry for #{inspect bucket} in table #{inspect table}"
  end

  def get_entry(bucket, table) do
    first = :binary.first(bucket)
    Enum.find(table, fn {enum, _node} ->
      first in enum
    end) || no_entry_error(bucket, table)
  end

  # def table() do
  #   Application.fetch_env!(:kv, :routing_table)

  #   # computer_name = Dotenv.get("COMPUTER_NAME")
  #   # if computer_name == nil do
  #   #   raise "COMPUTER_NAME is not set"
  #   # end

  #   # [{?a..?m, :"foo@#{computer_name}"}, {?n..?z, :"bar@#{computer_name}"}]
  # end
end
