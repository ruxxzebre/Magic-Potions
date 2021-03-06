defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.BearView

  def index(conv) do
    items =
      Wildthings.list_bears()
      # |> Enum.filter(fn(b) -> Bear.is_grizzly(b) end)
      # |> Enum.sort(fn(b1, b2) -> Bear.order_asc_by_name(b1, b2) end)
      # |> Enum.map(fn(b) -> bear_item(b) end)
      |> Enum.sort(&Bear.order_asc_by_name/2)

    # content =
    #   @template_path
    #   |> Path.join("index.eex")
    #   # TODO: why able to drop square brackets
    #   # |> EEx.eval_file([bears: items])
    #   |> EEx.eval_file(bears: items)

    %{conv | status: 200, resp_body: BearView.index(items)}
  end

  def show(conv, %{"id" => id}) do
    item = Wildthings.get_bear(id)

    # %{ conv | status: 200, resp_body: content }
    # render(conv, "show.eex", bear: bear)
    content = BearView.show(item)
    %{conv | status: 200, resp_body: content}
  end

  def create(conv, %{"type" => type, "name" => name}) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end

  def sensors(conv) do
    %{
      location: location,
      snapshots: snapshots
    } = Servy.SensorServer.get_sensor_data()

    # BearView.render(conv, "sensors.eex", location: location, snapshots: snapshots)
    %{conv | status: 200, resp_body: BearView.sensors(location, snapshots)}
  end

  def delete(conv, _params) do
    %{conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end
end
