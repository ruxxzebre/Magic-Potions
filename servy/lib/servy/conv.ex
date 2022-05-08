defmodule Servy.Conv.ReponseHeaders do
	defstruct content_type: "text/html",
	content_length: 0
end

defmodule Servy.Conv do
	alias Servy.Conv.ReponseHeaders

	@moduledoc """
	Conversation map
	"""
	defstruct method: "",
		path: "",
		params: %{},
		headers: %{},
		query: %{},
		resp_headers: %ReponseHeaders{},
		resp_body: "",
		status: nil

	def full_status(conv) do
		"#{conv.status} #{status_reason(conv.status)}"
	end

	defp status_reason(code) do
		%{
			200 => "OK",
			201 => "Created",
			401 => "Unauthorized",
			403 => "Forbidden",
			404 => "Not Found",
			500 => "Internal Server Error"
		}[code]
	end
end
