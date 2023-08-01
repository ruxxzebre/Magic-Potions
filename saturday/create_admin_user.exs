# import Config

# config :saturday, Saturday.Repo,
#   database: Path.expand("./saturday_dev.db", Path.dirname(__ENV__.file)),
#   pool_size: 5,
#   stacktrace: true,
#   show_sensitive_data_on_connection_error: true

# Saturday.Repo.start_link([])
require Logger
case Saturday.Accounts.register_user(%{
  email: "admin3@admin.com",
  password: "Flexadmin1222@",
}) do
  {:ok, user} -> Logger.debug("User created: #{inspect user}")
  {:error, changeset} -> Logger.error("User not created: #{inspect changeset}")
end

# Saturday.Repo.(%Saturday.Accounts.User{
#   email: "admin2@admin.com",
#   password: "Flexadmin1@",
# })
