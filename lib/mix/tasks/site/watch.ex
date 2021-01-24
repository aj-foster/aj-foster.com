defmodule Mix.Tasks.Site.Watch do
  use Mix.Task

  @shortdoc "Starts a development server and watches assets"

  @impl true
  def run(args) do
    Mix.Task.run("compile", [])
    {:ok, _} = Application.ensure_all_started(:site)
    Mix.Tasks.Serum.Server.run(args)
  end
end
