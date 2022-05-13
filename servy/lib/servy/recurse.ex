defmodule Recurse do
  def loopy(list), do: loopy(list, 0)

  def loopy([head | tail], sum) do
    loopy(tail, sum + head)
  end

  def loopy([], sum), do: sum

  def tripple([head | tail]) do
    [head * 3 | tripple(tail)]
  end

  # ? Why error when making this func private
  #! (CompileError) defp tripple/1 already defined as def in lib/servy/recurse.ex:10
  def tripple([]), do: []

  def tailTripple(list), do: tailTripple(list, [])

  defp tailTripple([head | tail], result) do
    tailTripple(tail, [head * 3 | result])
  end

  defp tailTripple([], result), do: result |> Enum.reverse()

  def my_map([head | tail], func) do
    [func.(head) | my_map(tail, func)]
  end

  def my_map([], _func), do: []

  def my_map_tail(list, func), do: my_map_tail(list, func, [])

  def my_map_tail([head | tail], func, acc) do
    my_map_tail(tail, func, [func.(head) | acc])
  end

  def my_map_tail([], _func, acc), do: Enum.reverse(acc)
end

IO.inspect(Recurse.tripple([1, 2, 3, 4, 5]))
IO.inspect(Recurse.tailTripple([1, 2, 3, 4, 5]))
