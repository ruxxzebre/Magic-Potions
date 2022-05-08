defmodule DocTest do
  use ExUnit.Case
  doctest Servy.Handler
  doctest Servy.Parser
  doctest Servy.Plugins
end
