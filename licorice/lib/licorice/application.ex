defmodule Licorice.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _opts) do
    children = [
      # Starts a worker by calling: Licorice.Worker.start_link(arg)
      # {Licorice.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Licorice.Router.Main, options: [port: 4000]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Licorice.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
