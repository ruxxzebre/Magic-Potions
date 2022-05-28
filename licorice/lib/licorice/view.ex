defmodule Licorice.View do
  import Plug.Conn

  @template_dir "lib/licorice/templates"

  def render(%{status: status} = conn, template, assigns \\ []) do
    body =
      @template_dir
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns)

    send_resp(conn, (status || 200), body)
  end

  def render_json(conn, status \\ 200, content) when is_map(content) do
    send_resp(conn, status, Poison.encode!(content))
  end
end
