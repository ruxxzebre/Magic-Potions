defmodule Servy.Conv do
  @moduledoc """
  Conversation map
  """
  defstruct method: "",
            path: "",
            params: %{},
            headers: %{},
            query: %{},
            req_body: "",
            resp_headers: %{
              "Content-Type" => "text/html"
            },
            resp_body: "",
            status: nil

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end
