defmodule TestUtils do
  def prepare_request(method, path) do
    method = cond do
      is_atom(method) -> String.upcase(Atom.to_string(method))
      true -> method
    end
    """
    #{method} #{path} HTTP/1.1\r
    HOST: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """
  end
end

defmodule HandlerTest do
  use ExUnit.Case

  import Servy.Handler, only: [handle: 1]
  import TestUtils, only: [prepare_request: 2]

  test "GET /wildthings" do
    request = prepare_request(:get, "/wildthings")

    response = handle(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """
  end

  test "DELETE /bears/id" do
    id = 1
    request = prepare_request(:delete, "/bears/#{id}")
    response = handle(request)

    assert response == """
    HTTP/1.1 403 Forbidden\r
    Content-Type: text/html\r
    Content-Length: 29\r
    \r
    Deleting a bear is forbidden!
    """
  end

  test "GET /api/bears" do
    request = prepare_request(:get, "/api/bears")
    response = handle(request)
    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: application/json\r
    Content-Length: 366\r
    \r
    [{\"type\":\"Brown\",\"name\":\"Teddy\",\"id\":1,\"hibernating\":true},{\"type\":\"Black\",\"name\":\"Smokey\",\"id\":2,\"hibernating\":false},{\"type\":\"Brown\",\"name\":\"Paddington\",\"id\":3,\"hibernating\":false},{\"type\":\"Grizzly\",\"name\":\"Scarface\",\"id\":4,\"hibernating\":true},{\"type\":\"Polar\",\"name\":\"Snow\",\"id\":5,\"hibernating\":false},{\"type\":\"Grizzly\",\"name\":\"Brutus\",\"id\":6,\"hibernating\":false}]
    """
  end
end
