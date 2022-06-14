defmodule PostgectoTest do
  use ExUnit.Case
  doctest Postgecto

  test "greets the world" do
    assert Postgecto.hello() == :world
  end
end
