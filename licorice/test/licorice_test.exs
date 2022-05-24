defmodule LicoriceTest do
  use ExUnit.Case
  doctest Licorice

  test "greets the world" do
    assert Licorice.hello() == :world
  end
end
