defmodule BoneTest do
  use ExUnit.Case
  doctest Bone

  test "greets the world" do
    assert Bone.hello() == :world
  end
end
