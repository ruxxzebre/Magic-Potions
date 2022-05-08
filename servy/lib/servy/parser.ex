defmodule Servy.Parser do
	# * alias Servy.Conv, as: Conv
	alias Servy.Conv # * same as top example

	def parse(request) do
		[top, params_string] = String.split(request, "\n\n")

		[request_line | header_lines] = String.split(top, "\n")

		[method, path, _] = String.split(request_line, " ")

		headers = parse_headers(header_lines)

		params = parse_params(headers["Content-Type"], params_string)

		%Conv{
			method: method,
			path: path,
			params: params,
			headers: headers,
			resp_body: "",
			status: nil
		}
	end

	defp parse_params("application/x-www-form-urlencoded", params_string) do
		params_string |> String.trim |> URI.decode_query
	end

	defp parse_params(_, _), do: %{}

	defp parse_headers(headers) do
		headers
		|> Enum.map(&String.split(&1, ": "))
		|> Enum.reduce(%{}, &(Map.put(&2, hd(&1), hd(tl(&1)))))
		# |> Enum.reduce(%{}, fn (el, acc) -> Map.put(acc, List.first(el), List.last(el)) end)
	end
end
