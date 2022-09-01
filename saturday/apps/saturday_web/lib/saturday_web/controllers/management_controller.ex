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

  def index(conn, %{"table" => "hide"} = params) do
    render(conn, "index.html", render_table: false)
  end

  def index(conn, _params) do
    render(conn, "index.html", render_table: true)
  end
end
