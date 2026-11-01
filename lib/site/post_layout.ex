defmodule Site.PostLayout do
  use Tableau.Layout, layout: Site.Layout

  import Temple
  import Phoenix.HTML, only: [raw: 1]

  def template(assigns) do
    assigns |> page() |> Phoenix.HTML.safe_to_string()
  end

  defp page(assigns) do
    temple do
      h1 id: heading_id(@page.title) do
        @page.title
      end

      p do
        "Posted on #{Calendar.strftime(@page.date, "%b %d, %Y")}. "

        a href: "https://github.com/aj-foster/aj-foster.com/discussions" do
          "Discuss on GitHub"
        end
      end

      div class: "article" do
        raw(render(@inner_content))
      end
    end
  end

  defp heading_id(title), do: Site.MarkdownConverter.heading_id(title, "")
end
