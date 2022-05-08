defmodule Servy.Api.BearController do

  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!

    conv = put_in(conv.resp_headers.content_type, "application/json")
    # |> Map.put("status", 200)
    # |> Map.put("resp_body", json)

    %{ conv | status: 200, resp_body: json }
  end
end
