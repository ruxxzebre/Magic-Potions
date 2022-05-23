defmodule Timer do
  def remind(str, sec) do
    spawn(fn ->
      :timer.sleep(sec * 1000)
      IO.puts(str)
    end)
  end
end
