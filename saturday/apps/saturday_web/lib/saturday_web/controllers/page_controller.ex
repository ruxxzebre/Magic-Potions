defmodule SaturdayWeb.PageController do
  use SaturdayWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
