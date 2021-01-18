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
      {:microscope, "1.3.0"},
      {:sass_compiler, "~> 0.1"},
      {:makeup, "~> 1.0"},
      {:makeup_c, ">= 0.0.0"},
      {:makeup_elixir, ">= 0.0.0"}
    ]
  end
end
