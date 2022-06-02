defmodule Marshall.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Marshall.Repo,
      # Start the Telemetry supervisor
      MarshallWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Marshall.PubSub},
      # Start the Endpoint (http/https)
      MarshallWeb.Endpoint
      # Start a worker by calling: Marshall.Worker.start_link(arg)
      # {Marshall.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Marshall.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MarshallWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
