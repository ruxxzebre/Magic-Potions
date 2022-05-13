defmodule Servy.FileHandler do
  alias Servy.Conv

  def handle_file({:ok, content}, conv) do
    %Conv{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %Conv{conv | status: 200, resp_body: "File not found."}
  end

  def handle_file({:error, reason}, conv) do
    %Conv{conv | status: 500, resp_body: "File error: #{reason}"}
  end

  def serve_markdown_file(filesPath, %Conv{} = conv, path) do
    page_path =
      filesPath
      |> Path.join("#{path}.md")

    {code, file} = page_path |> File.read()

    handle_file({code, Earmark.as_html!(file)}, conv)
  end

  def serve_file(filesPath, %Conv{} = conv, path) do
    filesPath
    |> Path.join("#{path}.html")
    |> File.read()
    |> handle_file(conv)
  end
end
