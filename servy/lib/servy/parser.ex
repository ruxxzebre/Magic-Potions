defmodule Servy.Parser do
	# * alias Servy.Conv, as: Conv
	alias Servy.Conv # * same as top example

	def parse(request) do
		[top, params_string] = String.split(request, "\r\n\r\n")

		[request_line | header_lines] = String.split(top, "\n")

		[method, path, _] = String.split(request_line, " ")

		{uri, query} = parse_query(path)

		headers = parse_headers(header_lines)

		params = parse_params(headers["Content-Type"], params_string)

		%Conv{
			method: method,
			path: uri,
			params: params,
			query: query,
			headers: headers,
			resp_body: "",
			status: nil
		}
	end

	@doc """
	Parses the given param string of the form `key1=value1&key2=value2`
	into a map with corresponding keys and values.

	## Examples

			iex> params_string = "name=Baloo&type=Brown"
			iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
			%{"name" => "Baloo", "type" => "Brown"}
			iex> Servy.Parser.parse_params("multipart/form-data", params_string)
			%{}

	"""
	def parse_params("application/x-www-form-urlencoded", params_string) do
		params_string |> String.trim |> URI.decode_query
	end

	def parse_params(_, _), do: %{}

	@doc """
	Parses given header lines into a map

	## Example

			iex> headers = ["Accept: */*", "HOST: example.com"]
			iex> Servy.Parser.parse_headers(headers)
			%{"Accept" => "*/*", "HOST" => "example.com"}

	"""
	def parse_headers(headers) do
		headers
		|> Enum.map(&String.split(&1, ": "))
		|> Enum.reduce(%{}, &(Map.put(&2, hd(&1), hd(tl(&1)))))
		# |> Enum.reduce(%{}, fn (el, acc) -> Map.put(acc, List.first(el), List.last(el)) end)
	end

	@doc """
	Parses given path into uri and query map

	## Example

			iex> path = "/books?decorate=true"
			iex> Servy.Parser.parse_query(path)
			{"/books", %{"decorate" => "true"}}
			iex> Servy.Parser.parse_query("/books")
			{"/books", %{}}

	"""
	def parse_query(path) do
		[uri | query] = path |> String.split("?")
		case query do
			[query_string] -> {uri, query_string |> URI.decode_query}
			[] -> {uri, %{}}
		end
	end
end
