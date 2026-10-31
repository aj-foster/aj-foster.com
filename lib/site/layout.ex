defmodule Site.Layout do
  use Tableau.Layout

  require EEx

  EEx.function_from_file(
    :def,
    :template,
    Path.join(File.cwd!(), "templates/base.html.eex"),
    [:assigns]
  )
end
