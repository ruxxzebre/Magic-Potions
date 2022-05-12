defmodule Servy.FileHandler do
	alias Servy.Conv

	def handle_file({ :ok, content }, conv) do
		%Conv{ conv | status: 200, resp_body: content }
	end

	def handle_file({ :error, :enoent }, conv) do
		%Conv{ conv | status: 200, resp_body: "File not found." }
	end

	def handle_file({ :error, reason }, conv) do
		%Conv{ conv | status: 500, resp_body: "File error: #{reason}" }
	end

	# TODO: fix this
	def serve_file(filesPath, %Conv{} = conv, "faq" = path) do
		page_path = filesPath
			|> Path.join("#{path}.md")

		{flag, file} = page_path |> File.read

		handle_file({flag, Markdown.to_html(file)}, conv)
	end

	def serve_file(filesPath, %Conv{} = conv, path) do
		filesPath
			|> Path.join("#{path}.html")
			|> File.read
			|> handle_file(conv)
	end
end
