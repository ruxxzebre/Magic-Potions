defmodule Saturday.Repo do
  use Ecto.Repo,
    otp_app: :saturday,
    adapter: Ecto.Adapters.SQLite3
end
