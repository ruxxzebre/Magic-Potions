defmodule Marshall.Repo do
  use Ecto.Repo,
    otp_app: :marshall,
    adapter: Ecto.Adapters.Postgres
end
