defmodule Site.MixFile do
  use Mix.Project

  def project do
    [
      app: :site,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:serum],
      mod: {Site.Application, []}
    ]
  end

  defp deps do
    [
      {:serum, "~> 1.5"},
      {:earmark, "~> 1.4.23", override: true},
      {:microscope, "1.4.0"},
      {:sass_compiler, "~> 0.1"},
      {:makeup, "~> 1.2"},
      {:makeup_c, "~> 0.1.1"},
      {:makeup_elixir, "~> 1.0"},
      {:makeup_erlang, "~> 1.0"},
      {:makeup_json, "~> 1.0"},
      {:makeup_swift, "~> 0.0.2"}
    ]
  end
end
