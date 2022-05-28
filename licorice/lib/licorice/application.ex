defmodule Licorice.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @fallback_port 3000

  @impl true
  def start(_type, _opts) do
    Logger.info("Starting a Licorice webserver...")
    port = Application.get_env(:licorice, :port, @fallback_port)
    Application.put_env(:licorice, :url, "http://localhost:#{port}")
    children = [
      # Starts a worker by calling: Licorice.Worker.start_link(arg)
      # {Licorice.Worker, arg}
      {Licorice.SessionServer, []},
      {Licorice.UsersStore, []},
      {Plug.Cowboy, scheme: :http, plug: Licorice.Router.Main, options: [port: port]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Licorice.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)
    Logger.info("Webserver started on port #{port}")
    {:ok, pid}
  end
end
