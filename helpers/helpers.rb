module Helpers

  def get_articles(count = 0)
    articles = sitemap.where(layout: "article")
      .order_by(:date)
      .all
      .select{ |a| a.data.published.nil? || a.data.published }
      .reverse

    if count == 0
      return articles
    else
      return articles.first(count)
    end
  end

  def meta_page_image
    if current_page.data.image
      locals = {
        url: "#{site.url}#{current_page.data.image}",
        height: current_page.data.image_height,
        width: current_page.data.image_width,
        type: current_page.data.image_type,
        unique: true
      }
    else
      locals = {
        url: "#{site.url}#{site.image}",
        height: "240",
        width: "240",
        type: "image/jpeg",
        unique: (current_page.url == "/")
      }
    end

    partial "layouts/og_image", locals: locals
  end

  def meta_page_type
    if current_page.data.layout == "article"
      locals = {
        type: "article",
        author: current_page.data.author || "AJ Foster",
        category: current_page.data.category,
        date: current_page.data.date,
        tags: current_page.data.tags
      }
    else
      locals = {
        type: "website",
        author: "AJ Foster",
        category: nil,
        date: nil,
        tags: nil
      }
    end

    partial "layouts/og_type", locals: locals
  end

  def page_description
    escape_html(current_page.data.description || site.description)
  end

  def page_title
    if current_page.data.title
      escape_html("#{current_page.data.title} | #{site.title}")
    else
      escape_html("#{site.title} | Web & Math")
    end
  end

  def page_url
    "#{site.url}#{current_page.url}"
  end
end