defmodule Site.PostLayout do
  use Tableau.Layout, layout: Site.Layout

  require EEx

  EEx.function_from_file(
    :def,
    :template,
    Path.join(File.cwd!(), "templates/post.html.eex"),
    [:assigns]
  )

  defp heading_id(title), do: Site.MarkdownConverter.heading_id(title, "")
end
