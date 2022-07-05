defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    # * start_supervised! creates a new supervised process for each test
    # * and guarantees that it'll be killed afterwards
    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawn buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error
    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    # Waiting for handle_info to process bucket's death
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "ensures registry state when bucket is exited normally", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    KV.Registry.create(registry, "cats")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
    assert KV.Registry.lookup(registry, "cats") != :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket, :shutdown)
    _ = KV.Registry.create(registry, "bogus")
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
