defmodule TierlistWeb.PageController do
  use TierlistWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
