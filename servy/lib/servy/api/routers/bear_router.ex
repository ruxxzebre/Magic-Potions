defmodule Servy.Api.BearRouter do
  alias Servy.Conv
  alias Servy.Api.BearController

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    BearController.create(conv)
  end
end
