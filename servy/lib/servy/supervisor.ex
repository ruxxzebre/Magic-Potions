defmodule Servy.Supervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts "Starting the supervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.KickStarter,
      Servy.ServiceSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
