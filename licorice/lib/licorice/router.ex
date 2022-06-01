defmodule Licorice.UserController do
end

defmodule Licorice.Router.Main do
  use Plug.Router
  import Plug.Conn
  alias Licorice.UsersStore

  # plug(Plug.Session, store: :ets, key: "sid", table: :session)
  plug(
    Plug.Session,
    store: :cookie,
    key: "_my_app_session",
    encryption_salt: "cookie store encryption salt",
    signing_salt: "cookie store signing salt",
    key_length: 64,
    log: :debug
  )
  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )
  plug :put_secret_key_base

  plug Plug.Static,
  from: {:licorice, "licorice/templates"},
  at: "/public"

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  def put_secret_key_base(conn, _) do
    put_in(conn.secret_key_base, "LONGSTRING")
  end

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  get "/login" do
    conn = fetch_cookies(conn)
    if Map.get(conn.cookies, "supersecretchat") != nil do
      conn |> resp(:found, "") |> put_resp_header(
        "location",
        "http://localhost:4000"
      )
    else
      Licorice.View.render(conn, "login.html", [])
    end
  end

  get "/cookie" do
    conn =
      fetch_cookies(conn, signed: ~w(supersecretchat))
      |> put_resp_cookie("cooked#{:rand.uniform(100)}", "#{:rand.uniform(1000)}", sign: true)

    conn |> send_resp(200, "DULL")
  end

  get "/register" do
    conn = fetch_cookies(conn, signed: ~w(supersecretchat))
    # val = Map.get(conn.cookies, "supersecretchat")
    IO.inspect(conn)
    Licorice.View.render(conn, "register.html", [])
  end

  get "/api/" do
    send_resp(conn, 200, "api route...")
  end

  get "/testurl" do
    conn |> Plug.Conn.resp(:found, "") |> Plug.Conn.put_resp_header("location", "https://www.google.com")
  end

  post "/api/users/login" do
    %{
      "name" => name, "pass" => pass,
    } = conn.body_params
    user = %UsersStore.User{name: name, hashed_password: pass}

    conn = fetch_cookies(conn, signed: ~w(supersecretchat))

    if Map.get(conn.cookies, "supersecretchat") != nil do
      conn |> resp(:found, "") |> put_resp_header(
        "location",
        "https://www.google.com"
      )
    end
    # |> put_resp_cookie("supersecretchat", %{name: name, pass: pass}, sign: true)



    # case UsersStore.get_user(user) do
    #   {:ok, _} ->
    #     conn
    #   {:error, reason} ->
    #     conn
    #   _ -> conn
    # end |> Licorice.View.render_json(%{ok: true})

    # ! REDIRECT
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
