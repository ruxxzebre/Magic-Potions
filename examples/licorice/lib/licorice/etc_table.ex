defmodule Licorice.ETC do
  @spec new_table :: atom | :ets.tid()
  def new_table do
    :ets.new(:session, [:named_table, :public, read_concurrency: true])
  end
end
