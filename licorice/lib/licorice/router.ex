defmodule Licorice.Router.Users do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "users route...")
  end

  get "/login" do
    send_resp(conn, 200, "logged in...")
  end
end

defmodule Licorice.Router.Main do
  use Plug.Router

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

  get "/" do
    Licorice.View.render(conn, "chat.html", [])
  end

  forward("users", to: Licorice.Router.Users)

  match _ do
    send_resp(conn, 404, "#{inspect(conn.request_path)} Not found")
  end
end
