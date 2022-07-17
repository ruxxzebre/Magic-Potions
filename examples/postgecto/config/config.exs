import Config

config :postgecto, Trains.Repo,
  database: "postgecto_repo",
  # username: "user",
  # password: "pass",
  hostname: "localhost"

config :postgecto,
  ecto_repos: [Trains.Repo]
