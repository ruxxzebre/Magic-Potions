defmodule Licorice.JSON do
  import Plug.Conn

  def render_json(%{status: status} = conn, data) do
    body = Jason.encode!(data)
    send_resp(conn, (status || 200), body)
  end
end
