defmodule Trains.Repo do
  use Ecto.Repo,
    otp_app: :postgecto,
    adapter: Ecto.Adapters.Postgres
end
