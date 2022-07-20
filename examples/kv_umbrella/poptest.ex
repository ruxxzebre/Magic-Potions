defmodule PopBench do
  use Benchfella

  @list Enum.to_list(1..1000)

  bench "reverse" do
    [_head|tail] = Enum.reverse(@list)
    Enum.reverse(tail)
  end

  bench "take" do
    Enum.take(@list, length(@list) - 1)
  end

  bench "drop" do
    Enum.drop(@list, -1)
  end
end
