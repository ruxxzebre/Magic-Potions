defmodule Servy.Handler do
	require Logger

	# Explicitly import only log function
	# if we just import module, we'll have all functions interpolated inside current
	# so it could mess things up a little bit
	# import Servy.Plugins, only: [log: 2, rewrite_request: 2] # 2 is arity of function
	import Servy.Plugins
	import Servy.Parser, only: [parse: 1]
	import Servy.FileHandler, only: [handle_file: 2]

	alias Servy.Conv
	alias Servy.BearController, as: BearController

	@moduledoc """
	Handles HTTP requests
	"""

	# Value set on compile time
	@pages_path Path.expand("../../pages", __DIR__)

	@doc "Transforms request to response"
	def handle(request) do
		request
		|> parse
		|> rewrite_request
		|> log(:request) # don't need prefix because of imported Servy.Plugins
		|> route
		|> decorate
		|> Servy.Plugins.log(:response) # another usage example
	end

	# * Routing with pages could be done this way
	# def route(%{ method: "GET", path: "/about" } = conv) do
	# 	file =
	# 		Path.expand("../../pages", __DIR__)
	# 		|> Path.join("about.html")

	# 	case File.read(file) do
	# 		{:ok, content} ->
	# 			%Conv{ conv | status: 200, resp_body: content }

	# 		{:error, :enoent} ->
	# 			%Conv{ conv | status: 404, resp_body: "File not found." }

	# 		{:error, reason} ->
	# 			%Conv{ conv | status: 500, resp_body: "File error: #{reason}" }
	# 	end
	# end

	def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
		%Conv{ conv | resp_body: "Bears, Lions, Tigers", status: 200 }
	end

	def route(%Conv{method: "GET", path: "/bears"} = conv) do
		BearController.index(conv)
	end

	def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
		serve_file(conv, "form.html")
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

	def route(%Conv{method: "GET", path: "/pages/" <> page } = conv) do
		serve_file(conv, "#{page}.html")
	end

	def route(%Conv{path: path} = conv) do
		%Conv{ conv | resp_body: "No #{path} here!", status: 404 }
	end

	def decorate(%Conv{ status: 404, resp_body: resp_body } = conv) do
		%Conv{ conv | resp_body: "#{String.duplicate("🚫", 10)}\n#{resp_body}\n#{String.duplicate("⛔️", 10)}" }
	end

	def decorate(%Conv{ status: 403, resp_body: resp_body } = conv) do
		%Conv{ conv | resp_body: "#{String.duplicate("😈", 10)}\n#{resp_body}\n#{String.duplicate("⛔️", 10)}" }
	end

	def decorate(%Conv{ status: 200, resp_body: resp_body } = conv) do
		%Conv{ conv | resp_body: "#{String.duplicate("😘", 10)}\n#{resp_body}\n#{String.duplicate("🥰", 10)}" }
	end

	def decorate(%Conv{} = conv), do: conv

	def format_response(%Conv{} = conv) do
		"""
		HTTP/1.1 #{Conv.full_status(conv)}
		Content-Type: text/html
		Content-Length: #{byte_size(conv.resp_body)}

		#{conv.resp_body}
		"""
	end

	defp serve_file(%Conv{} = conv, path) do
		@pages_path
			|> Path.join(path)
			|> File.read
			|> handle_file(conv)
	end
end


request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.inspect response
