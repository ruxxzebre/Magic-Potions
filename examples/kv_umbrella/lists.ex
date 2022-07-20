
defmodule Lists do
  def update([], _, _), do: :error

  def update([_|tail], 0, new_elem), do: [new_elem|tail]

  def update([head|tail], index, new_elem) do
    case update(tail, index - 1, new_elem) do
      :error -> :error
      new_tail -> [head|new_tail]
    end
  end
end

list = [1,2,3,4,5]
IO.inspect(Lists.update(list,0,10))
IO.inspect(Lists.update(list,4,10))
