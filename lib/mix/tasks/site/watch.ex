defmodule Mix.Tasks.Site.Watch do
  use Mix.Task

  @shortdoc "Starts a development server and watches assets"

  @impl true
  def run(args) do
    Mix.Task.run("compile", [])
    Application.put_env(:tableau, :server, true)
    {:ok, _} = Application.ensure_all_started(:site)
    Site.Assets.copy()
    Mix.Task.run("tableau.server", args)
  end
end
