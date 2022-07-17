defmodule Licorice.View do
  import Plug.Conn
  alias Licorice.ViewComponents
  alias Licorice.Helpers

  @template_dir Helpers.get_template_dir()

  def render(%{status: status} = conn, template, assigns \\ []) do
    body =
      @template_dir
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns |> populate_assigns(
        extract_necessary_cookies(conn)
      ))

    send_resp(conn, status || 200, body)
  end

  @spec extract_necessary_cookies(Plug.Conn.t()) :: map()
  defp extract_necessary_cookies(_conn) do
    %{navbar: %{logged_in: true}}
    # cookies = fetch_cookies(conn)
    # |> Map.get("cookies", nil)

    # case cookies do
    #   nil -> conn
    #   _ ->
    #     %{
    #       navbar: cookies["name"] != nil && cookies["pass"] != nil
    #     }
    # end
  end

  defp get_populated_components(opts \\ %{}) do
    [head: %{}, navbar: %{
      logged_in: true
    }]
    |> Enum.map(
      fn ({k, v}) -> { k, ViewComponents.render(v, k) } end
    )
  end

  defp populate_assigns(assigns \\ [], opts \\ %{}) do
    comps = get_populated_components(opts)
    vars = [url: Helpers.get_url()]
    assigns |> Keyword.merge(comps) |> Keyword.merge(vars)
  end

  def render_json(conn, status \\ 200, content) when is_map(content) do
    send_resp(conn, status, Poison.encode!(content))
  end
end
