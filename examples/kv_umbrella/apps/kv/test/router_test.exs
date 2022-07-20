defmodule KV.RouterTest do
  use ExUnit.Case

  # TODO: https://elixirforum.com/t/is-it-possible-to-have-elixir-running-with-a-custom-node-name-during-tests/44048/8

  setup_all do
    computer_name = "0.0.0.0"

    foo_node = String.to_atom("foo@#{computer_name}")
    bar_node = String.to_atom("bar@#{computer_name}")

    %{routing_table:
      [{?a..?m, foo_node}, {?n..?z, bar_node}],
      nodes: {foo_node, bar_node}}
  end

  test "route requests across nodes", %{routing_table: routing_table, nodes: nodes} do
    {foo_node, bar_node} = nodes

    :net_kernel.start([foo_node])
    :net_kernel.start([bar_node])

    assert KV.Router.route("hello", Kernel, :node, [], routing_table) == foo_node
    assert KV.Router.route("world", Kernel, :node, [], routing_table) == bar_node
  end

  test "raises on unknown entries", %{routing_table: routing_table} do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [], routing_table)
    end
  end
end
