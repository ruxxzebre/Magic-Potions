defmodule SaturdayWeb.ManagementController do
  alias Saturday.Entries
  use SaturdayWeb, :controller
  import Plug.Conn

  def download_report(conn, _params) do
    case Saturday.XLSX.Report.run() do
      {:error, _} ->
        conn
        |> send_resp(500, "Server error.")
      {:ok, path} ->
        Task.async(fn -> File.rm!(path) end)

        conn
        |> put_resp_content_type("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
        |> put_resp_header("Content-Disposition:", "attachment;filename=report.xlsx")
        |> put_root_layout(false)
        |> send_resp(200, File.read!(path))
    end
  end

  def index(conn, %{"table" => _}) do
    table_data = Entries.list_entries(:format_fields)

    render(conn, "index.html", render_table: true, table_data: table_data)
  end

  def index(conn, params) do
    params |> IO.inspect
    render(conn, "index.html", render_table: false)
  end
end
