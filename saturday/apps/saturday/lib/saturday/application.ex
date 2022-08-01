defmodule Saturday.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Saturday.Repo,
      # Start the Queue agent.
      # Should be initialized after Ecto (Sqturday.Repo), 'cause module depends on it
      Saturday.Queue,
      Saturday.Schedule.MemStorage,
      # Start the PubSub system
      {Phoenix.PubSub, name: Saturday.PubSub}
      # Start a worker by calling: Saturday.Worker.start_link(arg)
      # {Saturday.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Saturday.Supervisor)
  end
end
