defmodule MarshallWeb.PageController do
  use MarshallWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
