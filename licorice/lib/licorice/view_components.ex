defmodule Licorice.ViewComponents do
  alias Licorice.Helpers

  @template_dir Helpers.get_template_dir()

  @components %{
    navbar: "#{@template_dir}/navbar.html",
    head: "#{@template_dir}/head.html"
  }

  def render(%{logged_in: logged_in}, :navbar) do
    EEx.eval_file(
      @components[:navbar],
      url: Helpers.get_url(),
      logged_in: logged_in
    )
  end

  def render(opts, :navbar) do
    IO.puts "PUTTTZ _opts"
    IO.inspect opts
    EEx.eval_file(@components[:navbar], url: Helpers.get_url(),
    logged_in: false)
  end

  def render(_opts, :head) do
    EEx.eval_file(@components[:head], title: "DOC")
  end

  def render(opts, _), do: ""
end
