defmodule Servy.Plugins do
  alias Servy.Conv

  def log(conv, _type \\ true) do
    if Mix.env() == :dev do
      IO.inspect(conv)
    end

    conv
  end

  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env() != :test do
      IO.puts("Warning: #{path} is nonexistent.")
    end

    Servy.C404Counter.bump_count(path)
    conv
  end

  def track(%Conv{} = conv) do
    IO.inspect(conv)
    conv
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %Conv{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(conv, nil), do: conv

  def rewrite_request(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_request(conv), do: conv

  @doc """
  Decorates response based on status code

  ## Example
  		iex> %Servy.Conv{status: 404, resp_body: "data"} |> Servy.Plugins.decorate
  		%Servy.Conv{
  			headers: %{},
  			method: "",
  			params: %{},
  			path: "",
  			query: %{},
  			resp_body: "🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫\\ndata\\n⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️",
  			status: 404
  		}

  		iex> %{resp_body: resp_body} = %Servy.Conv{status: 404, resp_body: "data"} |> Servy.Plugins.decorate
  		iex> "🚫🚫🚫🚫🚫🚫🚫🚫🚫🚫\\ndata\\n⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️" = resp_body
  		iex> %{resp_body: resp_body} = %Servy.Conv{status: 403, resp_body: "data"} |> Servy.Plugins.decorate
  		iex> "😈😈😈😈😈😈😈😈😈😈\\ndata\\n⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️" = resp_body
  		iex> %{resp_body: resp_body} = %Servy.Conv{status: 200, resp_body: "data"} |> Servy.Plugins.decorate
  		iex> "😘😘😘😘😘😘😘😘😘😘\\ndata\\n🥰🥰🥰🥰🥰🥰🥰🥰🥰🥰" = resp_body
  		iex> %{resp_body: resp_body} = %Servy.Conv{status: 201, resp_body: "data"} |> Servy.Plugins.decorate
  		iex> "data" = resp_body
  """
  def decorate(%Conv{status: 404, resp_body: resp_body} = conv) do
    %Conv{
      conv
      | resp_body: "#{String.duplicate("🚫", 10)}\n#{resp_body}\n#{String.duplicate("⛔️", 10)}"
    }
  end

  def decorate(%Conv{status: 403, resp_body: resp_body} = conv) do
    %Conv{
      conv
      | resp_body: "#{String.duplicate("😈", 10)}\n#{resp_body}\n#{String.duplicate("⛔️", 10)}"
    }
  end

  def decorate(%Conv{status: 200, resp_body: resp_body} = conv) do
    %Conv{
      conv
      | resp_body: "#{String.duplicate("😘", 10)}\n#{resp_body}\n#{String.duplicate("🥰", 10)}"
    }
  end

  def decorate(%Conv{} = conv), do: conv
end
