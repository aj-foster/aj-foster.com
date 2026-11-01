defmodule Site.Layout do
  use Tableau.Layout

  import Temple
  import Phoenix.HTML, only: [raw: 1]

  def template(assigns) do
    assigns |> page() |> Phoenix.HTML.safe_to_string()
  end

  defp page(assigns) do
    temple do
      raw("<!doctype html>")

      html do
        head do
          meta(charset: "utf-8")
          meta(name: "viewport", content: "width=device-width, initial-scale=1.0")

          title do
            if @page[:title], do: "#{@page.title} • AJ Foster", else: "AJ Foster"
          end

          link(rel: "stylesheet", href: "/assets/css/app.css")
          link(rel: "preconnect", href: "https://fonts.gstatic.com")

          link(
            href:
              "https://fonts.googleapis.com/css2?family=Raleway:ital,wght@0,400;0,600;1,400&display=swap",
            rel: "stylesheet"
          )

          link(
            href:
              "https://fonts.googleapis.com/css2?family=Oranienbaum&display=swap&text=0123456789",
            rel: "stylesheet"
          )

          link(
            href: "/feed.xml",
            type: "application/rss+xml",
            rel: "alternate",
            title: "Sitewide RSS feed"
          )

          link(rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png")
          link(rel: "manifest", href: "/site.webmanifest")
          link(rel: "me", href: "https://hachyderm.io/@ajf")
        end

        body class: if(@page[:label], do: "page--#{String.downcase(@page.label)}") do
          div class: "cell well" do
            if @page[:group] == "main" do
              Site.Partials.logo()
            end

            section do
              Site.Partials.navigation()
              raw(render(@inner_content))
            end
          end

          if @page[:label] == "Home" do
            div class: "cell well" do
              h2 do
                "Writing"
              end

              for post <- Enum.take(@posts, 5) do
                listing(post)
              end
            end

            div class: "cell well" do
              a href: "/posts" do
                "See all posts"
              end
            end
          end

          if @page[:label] == "Posts" do
            div class: "cell well" do
              for post <- @posts do
                listing(post)
              end
            end
          end

          footer do
            div class: "darkmode" do
              input(type: "checkbox", id: "darkmode")

              label for: "darkmode" do
                "Toggle Dark Mode"
              end
            end

            div do
              "Created with ♥︎ by AJ Foster. "

              a href: "https://github.com/aj-foster/aj-foster.com/" do
                "Source"
              end
            end
          end

          script(
            defer: true,
            "data-domain": "aj-foster.com",
            src: "https://plausible.io/js/script.js"
          )

          script(async: true, defer: true, src: "/assets/js/colors.js")
        end
      end
    end
  end

  defp listing(post) do
    date = Calendar.strftime(post.date, "%b %d, %Y")
    <<month::binary-3, " ", day::binary-2, ", ", year::binary-4>> = date

    temple do
      a href: post.permalink, class: "listing" do
        div class: "date" do
          div class: "month" do
            month
          end

          div class: "day" do
            day
          end

          div class: "year" do
            year
          end
        end

        div class: "text" do
          div class: "title" do
            post.title
          end

          div class: "description" do
            post[:preview] || ""
          end
        end
      end
    end
  end
end
