defmodule Mix.Tasks.Site.Gen do
  use Mix.Task

  @shortdoc "Generates the site, including assets"

  @impl true
  def run(args) do
    Mix.Task.run("compile", [])
    {:ok, _} = Application.ensure_all_started(:site)
    File.rm_rf!("site")
    Site.Assets.copy()
    Mix.Task.run("tableau.build", args)
  end
end
