defmodule KVServer.CommandTest do
  use ExUnit.Case, async: true
  doctest KVServer.Command

  setup context do
    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

  test "create bucket command", %{registry: registry} do
    {:ok, "OK\r\n"} = KVServer.Command.run({:create, "shopping"}, registry)
    {:ok, pid} = KV.Registry.lookup(registry, "shopping")
    assert Process.alive?(pid) == true
  end

  test "put command", %{registry: registry} do
    KVServer.Command.run({:create, "shopping"}, registry)
    {:ok, "OK\r\n"} = KVServer.Command.run({:put, "shopping", "milk", 1}, registry)
    {:ok, value} = KVServer.Command.run({:get, "shopping", "milk"}, registry)
    assert value == "1\r\nOK\r\n"
  end

  test "get command", %{registry: registry} do
    KVServer.Command.run({:create, "shopping"}, registry)
    KVServer.Command.run({:put, "shopping", "milk", 1}, registry)
    {:ok, "1\r\nOK\r\n"} = KVServer.Command.run({:get, "shopping", "milk"}, registry)
  end

  test "delete key command", %{registry: registry} do
    KVServer.Command.run({:create, "shopping"}, registry)
    KVServer.Command.run({:put, "shopping", "milk", 1}, registry)
    {:ok, "OK\r\n"} = KVServer.Command.run({:delete, "shopping", "milk"}, registry)
    {:ok, value} = KVServer.Command.run({:get, "shopping", "milk"}, registry)
    assert value == "\r\nOK\r\n"
  end
end
