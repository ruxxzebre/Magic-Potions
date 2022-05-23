# TODO: nested routers

defmodule Servy.BearRouter do
  alias Servy.Conv
  alias Servy.BearController
  alias Servy.PledgeController
  import Servy.FileHandler
  @pages_path Path.expand("../../../pages", __DIR__)

  def route(%Conv{method: "GET", path: "/wildthings"} = conv),
    do: %{conv | resp_body: "Bears, Lions, Tigers", status: 200}

  def route(%Conv{method: "GET", path: "/sensors"} = conv), do: BearController.sensors(conv)

  def route(%Conv{method: "GET", path: "/sleep/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()
    %{conv | status: 200, resp_body: "Finally awake!"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv), do: BearController.index(conv)

  def route(%Conv{method: "GET", path: "/bears/new"} = conv),
    do: serve_file(@pages_path, conv, "form.html")

  def route(%Conv{method: "POST", path: "/bears"} = conv),
    do: BearController.create(conv, conv.params)

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv),
    do: BearController.show(conv, Map.put(conv.params, "id", id))

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv),
    do: BearController.delete(conv, conv.params)

  def route(%Conv{method: "GET", path: "/pages/pledges/new"} = conv),
    do: PledgeController.create(conv, nil)

  def route(%Conv{method: "GET", path: "/pages/pledges"} = conv),
    do: PledgeController.index(conv)

  def route(%Conv{method: "POST", path: "/pages/pledges/new"} = conv),
    do: PledgeController.create(conv, conv.params)

  def route(%Conv{method: "GET", path: "/pages/faq"} = conv) do
    serve_markdown_file(@pages_path, conv, "faq")
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page} = conv),
    do: serve_file(@pages_path, conv, page)

  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    {:ok, json} = Poison.encode(Servy.C404Counter.get_counts())
    %Conv{conv | status: 200, resp_body: json}
  end

  def route(%Conv{path: path} = conv) do
    %Conv{conv | resp_body: "No #{path} here!", status: 404}
  end
end
