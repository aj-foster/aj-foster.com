defmodule Site.MarkdownConverter do
  @heading ~r/<h([1-6])([^>]*?)\bid="([^"]*)"([^>]*)>(.*?)<\/h\1>/s
  @anchor ~r/<a\b(?=[^>]*\bclass="anchor")[^>]*><\/a>/
  @source_attributes ~r/^\{\s*:\s*((?:\.[[:alnum:]_-]+\s*)+)\}\s*$/m
  @block_attributes ~r/(<(table|p)\b[^>]*>.*?<\/\2>)\s*<!-- markdown-attributes: ((?:\.[[:alnum:]_-]+\s*)+) -->/s

  def convert(_filepath, _front_matter, body, %{site: %{config: config}}) do
    body
    |> mark_block_attributes()
    |> MDEx.to_html!(config.markdown[:mdex])
    |> Site.Highlight.highlight()
    |> preserve_heading_ids()
    |> preserve_block_attributes()
    |> String.replace(@anchor, "")
  end

  defp mark_block_attributes(body) do
    Regex.replace(@source_attributes, body, fn _match, classes ->
      "<!-- markdown-attributes: #{String.trim(classes)} -->"
    end)
  end

  defp preserve_block_attributes(html) do
    Regex.replace(@block_attributes, html, fn _match, block, tag, classes ->
      class_names =
        Regex.scan(~r/\.([[:alnum:]_-]+)/, classes)
        |> Enum.map(fn [_, class] -> class end)
        |> Enum.reverse()
        |> Enum.join(" ")

      String.replace_prefix(block, "<#{tag}", "<#{tag} class=\"#{class_names}\"")
    end)
  end

  def heading_id(text, prefix \\ "-") do
    text
    |> String.replace(~r/<[^>]*>/, "")
    |> HtmlEntities.decode()
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
    |> then(&(prefix <> &1))
    |> HtmlEntities.encode()
  end

  defp preserve_heading_ids(html) do
    Regex.replace(@heading, html, fn _match, level, before, _id, after_id, content ->
      id = heading_id(content)
      "<h#{level}#{before}id=\"#{id}\"#{after_id}>#{content}</h#{level}>"
    end)
  end
end
