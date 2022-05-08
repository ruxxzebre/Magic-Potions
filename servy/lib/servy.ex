defmodule Servy do
  def hello(name) do
    "Ahoy, #{name}!"
  end
end

IO.puts Servy.hello "Mike"