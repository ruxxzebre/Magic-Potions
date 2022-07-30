defmodule Saturday.Queue do
  @moduledoc """
  Generic server for processing entries by applicants one by one.
  """
  use GenServer

  # TODO: init from DB
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end
end
