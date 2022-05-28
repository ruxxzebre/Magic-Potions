defmodule Licorice.UserController do
end

defmodule Licorice.Router.Main do
  use Plug.Router
  import Plug.Conn
  alias Licorice.UsersStore

  @url Application.get_env(:licorice, :url)

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  get "/login" do
    Licorice.View.render(conn, "login.html", [url: @url])
  end

  get "/register" do
    Licorice.View.render(conn, "register.html", [url: @url])
  end

  get "/api/" do
    send_resp(conn, 200, "api route...")
  end

  get "/api/users/login" do
    %{
      "name" => name, "pass" => pass,
    } = conn.body_params
    send_resp(conn, 200, "logged in...")
  end

  post "/api/users/register" do
    %{
      "name" => name, "pass" => pass,
    } = conn.body_params
    user = %UsersStore.User{name: name, hashed_password: pass}
    case UsersStore.add_user(user) do
      {:ok, _id} ->
        conn |> Licorice.View.render_json(%{
          message: "User #{user.name} added"
        })
      {:error, reason} ->
        conn |> send_resp(400, reason)
    end
  end

  post "/api/users/all" do
    users = UsersStore.get_all_users()
    {:ok, json} = Poison.encode(users)
    send_resp(conn, 200, json)
  end

  get "/" do
    Licorice.View.render(conn, "chat.html", [])
  end

  get "/ping" do
    send_resp(conn, 200, "Alive!")
  end

  # forward("users", to: Licorice.Router.Users)

  match _ do
    send_resp(conn, 404, "#{inspect(conn.request_path)} Not found")
  end
end
