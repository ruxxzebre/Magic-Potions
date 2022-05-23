defmodule Servy.PledgeController do
  alias Servy.PledgeServer
  alias Servy.PledgeView
  alias Servy.Conv

  def create(conv, nil) do
    %{conv | status: 200, resp_body: PledgeView.create_pledge()}
  end

  def create(conv, %{"name" => name, "amount" => amount}) do
    PledgeServer.create_pledge(name, amount)
    %{conv | status: 200, resp_body: PledgeView.create_pledge()}
  end

  def create(conv, _) do
    %{conv | status: 405, resp_body: "Invalid params passed"}
  end

  def index(%Conv{} = conv) do
    pledges = PledgeServer.recent_pledges() |> Enum.map(& &1)
    %{conv | status: 200, resp_body: PledgeView.recent_pledges(pledges)}
  end
end
