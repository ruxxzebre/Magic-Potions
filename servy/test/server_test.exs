defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "test routes to respond with 200 status code" do
    serv_task = Task.async(HttpServer, :start, [4000])

    urls = [
      "api/bears",
      "wildthings",
      "sensors",
      "pages/faq"
    ]

    urls
    |> Enum.map(&Task.async(HTTPoison, :get, ["http://localhost:4000/#{&1}"]))
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_status_code/1)

    Task.shutdown(serv_task)
  end

  defp assert_status_code({:ok, response}) do
    assert response.status_code == 200
  end

  test "send 5 concurrent wildthings requests" do
    serv_task = Task.async(HttpServer, :start, [4000])
    url = "http://localhost:4000/wildthings"

    for _ <- 1..5 do
      Task.async(fn -> HTTPoison.get(url) end)
    end
    |> Enum.map(&Task.await/1)
    |> Enum.map(fn {code, res} ->
      assert code == :ok
      res.status_code == 200
      res.body == "Bears, Lions, Tigers"
    end)

    Task.shutdown(serv_task)
  end

  test "send request and accept response" do
    serv_task = Task.async(HttpServer, :start, [4000])

    get_url = fn u -> "http://localhost:4000/#{u}" end

    parent = self()

    urls = [
      "api/bears",
      "wildthings",
      "sensors",
      "pages/faq",
      "undefined"
    ]

    urls =
      urls
      |> Enum.map(fn url ->
        Task.async(fn -> {url, HTTPoison.get(get_url.(url))} end)
      end)

    for url <- urls do
      case Task.await(url) do
        {"api/bears", {:ok, response}} ->
          assert response.status_code == 200

          assert response.body ==
                   "[{\"type\":\"Brown\",\"name\":\"Teddy\",\"id\":1,\"hibernating\":true},{\"type\":\"Black\",\"name\":\"Smokey\",\"id\":2,\"hibernating\":false},{\"type\":\"Brown\",\"name\":\"Paddington\",\"id\":3,\"hibernating\":false},{\"type\":\"Grizzly\",\"name\":\"Scarface\",\"id\":4,\"hibernating\":true},{\"type\":\"Polar\",\"name\":\"Snow\",\"id\":5,\"hibernating\":false},{\"type\":\"Grizzly\",\"name\":\"Brutus\",\"id\":6,\"hibernating\":false},{\"type\":\"Black\",\"name\":\"Rosie\",\"id\":7,\"hibernating\":true},{\"type\":\"Panda\",\"name\":\"Roscoe\",\"id\":8,\"hibernating\":false},{\"type\":\"Polar\",\"name\":\"Iceman\",\"id\":9,\"hibernating\":true},{\"type\":\"Grizzly\",\"name\":\"Kenai\",\"id\":10,\"hibernating\":false}]"

        {"wildthings", {:ok, response}} ->
          assert response.status_code == 200
          assert response.body == "Bears, Lions, Tigers"

        {"sensors", {:ok, response}} ->
          assert response.status_code == 200

          assert response.body ==
                   "<h1>Sensors</h1>\n\n<div>\nX: 2\nY: 9\nZ: 55\n</div>\n<ul>\n\t\n\t\t<li>cam-1-snapshot.jpg</li>\n\t\n\t\t<li>cam-2-snapshot.jpg</li>\n\t\n\t\t<li>cam-3-snapshot.jpg</li>\n\t\n</ul>"

        {"pages/faq", {:ok, response}} ->
          assert response.status_code == 200

          assert response.body ==
                   "<h1>\nFrequently Asked Questions</h1>\n<ul>\n  <li>\n    <p>\n<strong>Have you really seen Bigfoot?</strong>    </p>\n    <p>\nYes! In this <a href=\"https://www.youtube.com/watch?v=v77ijOO8oAk\">totally believable video</a>!    </p>\n  </li>\n  <li>\n    <p>\n<strong>No, I mean seen Bigfoot <em>on the refuge</em>?</strong>    </p>\n    <p>\nOh! Not yet, but we’re <em>still looking</em>…    </p>\n  </li>\n  <li>\n    <p>\n<strong>Can you just show me some code?</strong>    </p>\n    <p>\nSure! Here’s some Elixir:    </p>\n    <pre><code class=\"elixir\">[&quot;Bigfoot&quot;, &quot;Yeti&quot;, &quot;Sasquatch&quot;] |&gt; Enum.random()</code></pre>\n  </li>\n</ul>\n"

        {"undefined", {:ok, response}} ->
          assert response.status_code == 404
          assert response.body == "No /undefined here!"
      end
    end

    # assert code == :ok
    # assert response.status_code == 200
    # assert response.body == """
    #     [{\"type\":\"Brown\",\"name\":\"Teddy\",\"id\":1,\"hibernating\":true},{\"type\":\"Black\",\"name\":\"Smokey\",\"id\":2,\"hibernating\":false},{\"type\":\"Brown\",\"name\":\"Paddington\",\"id\":3,\"hibernating\":false},{\"type\":\"Grizzly\",\"name\":\"Scarface\",\"id\":4,\"hibernating\":true},{\"type\":\"Polar\",\"name\":\"Snow\",\"id\":5,\"hibernating\":false},{\"type\":\"Grizzly\",\"name\":\"Brutus\",\"id\":6,\"hibernating\":false},{\"type\":\"Black\",\"name\":\"Rosie\",\"id\":7,\"hibernating\":true},{\"type\":\"Panda\",\"name\":\"Roscoe\",\"id\":8,\"hibernating\":false},{\"type\":\"Polar\",\"name\":\"Iceman\",\"id\":9,\"hibernating\":true},{\"type\":\"Grizzly\",\"name\":\"Kenai\",\"id\":10,\"hibernating\":false}]
    #     """ |> String.trim
  end
end
