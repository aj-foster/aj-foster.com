defmodule Site.Partials do
  require EEx

  EEx.function_from_file(
    :def,
    :logo,
    Path.join(File.cwd!(), "includes/aj.html.eex"),
    []
  )

  EEx.function_from_file(
    :def,
    :navigation,
    Path.join(File.cwd!(), "includes/nav.html.eex"),
    []
  )
end
