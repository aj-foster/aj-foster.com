defmodule Site.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Site.Sass
    ]

    opts = [strategy: :one_for_one, name: Site.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
