defmodule Servy.Api.BearRouter do
  alias Servy.Conv
  alias Servy.Api.BearController
  alias Servy.Api.PledgeController

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    BearController.create(conv)
  end

  def route(%Conv{method: "GET", path: "/api/pledges"} = conv) do
    PledgeController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/pledges"} = conv) do
    PledgeController.create(conv, conv.params)
  end
end
