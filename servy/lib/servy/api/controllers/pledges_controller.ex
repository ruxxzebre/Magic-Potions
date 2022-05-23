defmodule Servy.Api.PledgeController do
  import Servy.PledgeServer, only: [create_pledge: 2, recent_pledges: 0]
  alias Servy.Conv

  def create(%Conv{} = conv, %{"name" => name, "amount" => amount} = params) do
    create_pledge(name, String.to_integer(amount))
    %{conv | status: 201, resp_body: "#{params["name"]} pledged #{params["amount"]}!"}
  end

  def create(%Conv{} = conv, _) do
    %{conv | status: 400, resp_body: "No name or amount params provided!"}
  end

  def index(%Conv{} = conv) do
    pledges = recent_pledges()
    %{conv | status: 200, resp_body: inspect(pledges)}
  end
end
