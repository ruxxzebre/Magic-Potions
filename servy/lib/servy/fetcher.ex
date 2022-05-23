defmodule Servy.Fetcher do
  def async(func) do
    parent = self()

    spawn(fn -> send(parent, {self(), :result, func.()}) end)
  end

  @spec await(any) :: any
  def await(pid) do
    receive do
      {^pid, :result, value} -> value
    end
  end
end
