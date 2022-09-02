defmodule Mix.Tasks.CreateAdmin do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task
  alias Saturday.Accounts

  defp parse_args(args) do
    args
    |> Enum.map(&String.split(&1, "="))
    |> Enum.reduce(%{}, fn [key, value], acc ->
      Map.put(acc, key, value)
    end)
  end

  @shortdoc "Simply calls the Hello.say/0 function."
  def run(args) do
    args = parse_args(args)
    email = Map.get(args, "email")
    password = Map.get(args, "password")

    if email == nil
    || password == nil do
      raise "Email and Password options should be passed!"
    end

    connect_to_db()

    require Logger

    {:ok, user} = Accounts.register_user(%{
      email: email,
      password: password
    })

    Logger.info("User #{inspect(user)} created successfully.")
  end
end
