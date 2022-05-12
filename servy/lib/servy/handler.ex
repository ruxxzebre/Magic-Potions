defmodule Servy.Handler do
	require Logger

	# Explicitly import only log function
	# if we just import module, we'll have all functions interpolated inside current
	# so it could mess things up a little bit
	# import Servy.Plugins, only: [log: 2, rewrite_request: 2] # 2 is arity of function
	import Servy.Parser, only: [parse: 1]
	import Servy.Plugins, only: [rewrite_request: 1]

	alias Servy.Plugins
	alias Servy.Conv
	alias Servy.BearRouter, as: WebBearRouter
	alias Servy.Api.BearRouter, as: ApiBearRouter

	@moduledoc """
	Handles HTTP requests
	"""

	# Value set on compile time
	# @pages_path Path.expand("../../pages", __DIR__)

	@doc "Transforms request to response"
	def handle(request) do
		request
		|> parse
		|> rewrite_request
		|> Plugins.log()
		|> router
		# |> Plugins.decorate
		# |> Plugins.log
		|> fill_response_headers
		|> format_response
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

	def router(%Conv{ path: path } = conv) do
		case path do
			"/api" <> _path  -> ApiBearRouter.route(conv)
			_ -> WebBearRouter.route(conv)
		end
	end

	def fill_response_headers(%Conv{ resp_headers: resp_headers } = conv) do
		# * Another way of doing that, when resp_headers was a struct
		# put_in(conv.resp_headers.content_length, byte_size(conv.resp_body))
		%{ conv | resp_headers: resp_headers |> Map.put("Content-Length", byte_size(conv.resp_body)) }
	end

	def format_headers(%Conv{} = conv) do
		conv.resp_headers
		|> Enum.reduce([], fn ({ k, v }, acc) -> ["#{k}: #{v}\r" | acc] end)
		|> Enum.sort(:desc)
		|> Enum.join("\n")
	end

	def format_headers_com(%Conv{} = conv) do
		for {k, v} <- conv.resp_headers do
			"#{k}: #{v}\r"
		end
		|> Enum.sort(:desc)
		|> Enum.join("\n")
	end

	def format_response(conv) do
		"""
		HTTP/1.1 #{Conv.full_status(conv)}\r
		#{format_headers(conv)}
		\r
		#{conv.resp_body}
		"""
	end
end


# request = """
# GET /bears/1 HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*

# """

# response = Servy.Handler.handle(request)

# IO.inspect response
