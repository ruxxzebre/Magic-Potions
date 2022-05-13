defmodule Servy.BearView do
  require EEx

  @templates_path Path.expand("../../../templates", __DIR__)

  EEx.function_from_file(:def, :index, Path.join(@templates_path, "index.eex"), [:bears])

  EEx.function_from_file(:def, :show, Path.join(@templates_path, "show.eex"), [:bear])

  # * bindings \\ [] - means default value of an argument is [] (empty list)
  def render(conv, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %{conv | status: 200, resp_body: content}
  end
end
