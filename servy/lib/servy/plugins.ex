defmodule Servy.Plugins do
	alias Servy.Conv

	def log(conv, _type) do
		if Mix.env == :dev do
			IO.inspect conv
		end
		conv
	end

	def track(%Conv{status: 404, path: path} = conv) do
		if Mix.env != :test do
			IO.puts "Warning: #{path} is nonexistent."
		end
		conv
	end

	def track(%Conv{} = conv), do: conv

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
