defmodule UserApi do
  @url "https://jsonplaceholder.typicode.com/users/"

  def query(id) do
    cond do
      is_integer(id) ->
        id = to_string(id)
        handle_response(HTTPoison.get(@url <> id))

      is_binary(id) ->
        handle_response(HTTPoison.get(@url <> id))

      true ->
        {:error, %HTTPoison.Error{reason: "Invalid ID type"}}
    end
  end

  def handle_response({:ok, response}) do
    {:ok, body} = Poison.decode(response.body)

    case response.status_code do
      200 ->
        {:ok, get_in(body, ["address", "city"])}

      _ ->
        {:ok, get_in(body, ["message"])}
    end
  end

  def handle_response(res), do: res
end
