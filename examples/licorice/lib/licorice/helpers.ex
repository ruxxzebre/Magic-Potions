defmodule Licorice.Helpers do
  def get_url, do: Application.get_env(:licorice, :url)

  def get_template_dir, do: "lib/licorice/templates"
end
