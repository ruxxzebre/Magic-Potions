defmodule Servy.Api.BearController do
  alias Servy.Conv

  def index(%Conv{resp_headers: resp_headers} = conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!()

    headers = resp_headers |> Map.put("Content-Type", "application/json")
    %{conv | status: 200, resp_body: json, resp_headers: headers}
  end

  def create(%Conv{params: %{"name" => name, "type" => type}} = conv) do
    resp_body = "Created a #{type} bear named #{name}!"
    %{conv | status: 201, resp_body: resp_body}
  end
end
