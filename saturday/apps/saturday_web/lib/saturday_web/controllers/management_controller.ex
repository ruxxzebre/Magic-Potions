defmodule SaturdayWeb.ManagementController do
  use SaturdayWeb, :controller
  import Plug.Conn

  def download_report(conn, _params) do
    {:ok, path} = Saturday.XLSX.Report.run()

    conn = conn
    |> put_resp_content_type("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    |> put_resp_header("Content-Disposition:", "attachment;filename=report.xlsx")
    |> put_root_layout(false)
    |> send_resp(200, File.read!(path))

    File.rm!(path)

    conn
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
