defmodule Servy.Plugins do
	alias Servy.Conv

	def log(conv, _type) do
		IO.inspect conv
		conv
	end

	def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
		%Conv{ conv | path: "/#{thing}/#{id}" }
	end

	def rewrite_path_captures(conv, nil), do: conv

	def rewrite_request(%{ path: path } = conv) do
		regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
		captures = Regex.named_captures(regex, path)
		rewrite_path_captures(conv, captures)
	end

	def rewrite_request(conv), do: conv
end
