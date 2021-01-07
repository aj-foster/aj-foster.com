defmodule Mix.Tasks.Site.Gen do
  use Mix.Task

  @shortdoc "Generates the site, including assets"

  @impl true
  def run(args) do
    Mix.Task.run("compile", [])
    {:ok, _} = Application.ensure_all_started(:site)
    Mix.Tasks.Serum.Server.run(args)
  end
end
