defmodule Servy.BearRouter do
  alias Servy.Conv
  alias Servy.BearController
  import Servy.FileHandler
  @pages_path Path.expand("../../../pages", __DIR__)

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %Conv{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    serve_file(@pages_path, conv, "form.html")
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    BearController.show(conv, Map.put(conv.params, "id", id))
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pages/faq"} = conv) do
    serve_markdown_file(@pages_path, conv, "faq")
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page} = conv) do
    serve_file(@pages_path, conv, page)
  end

  def route(%Conv{path: path} = conv) do
    %Conv{conv | resp_body: "No #{path} here!", status: 404}
  end
end
