defmodule Site.MixFile do
  use Mix.Project

  def project do
    [
      app: :site,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Site.Application, []}
    ]
  end

  defp deps do
    [
      {:tableau, "~> 0.30"},
      # Use the patched MDEx release until Tableau relaxes its current version constraint.
      {:mdex, "~> 0.14.6", override: true},
      {:html_entities, "~> 0.5.2"},
      {:file_system, "~> 1.0"},
      {:dart_sass, "~> 0.8"},
      {:makeup, "~> 1.2"},
      {:makeup_c, "~> 0.1.1"},
      {:makeup_elixir, "~> 1.0"},
      {:makeup_erlang, "~> 1.0"},
      {:makeup_json, "~> 1.0"},
      {:makeup_swift, "~> 0.0.2"}
    ]
  end
end
