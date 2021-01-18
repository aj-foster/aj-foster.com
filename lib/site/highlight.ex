defmodule Site.Highlight do
  @moduledoc """
  Taken from https://github.com/dashbitco/nimble_publisher/blob/v0.1.1/lib/nimble_publisher/highlighter.ex

  Serum Plugin that adds syntax highlighing for supported languages.
  """

  @behaviour Serum.Plugin

  def name, do: "Highlighter"
  def version, do: "1.0.0"
  def elixir, do: "~> 1.11"
  def serum, do: "~> 1.5"
  def description, do: "Syntax highlighter for select languages"
  def implements, do: [rendered_fragment: 2]
  # def implements, do: [processed_post: 2]

  def rendered_fragment(frag, _args) do
    IO.inspect(frag)
    frag = Map.update!(frag, :data, &highlight/1)
    IO.inspect(frag)
    {:ok, frag}
  end

  # def processed_post(post, _args) do
  #   IO.inspect(post.html)
  #   post = Map.update!(post, :html, &highlight/1)
  #   IO.inspect(post.html)
  #   {:ok, post}
  # end

  # Everything below is copied.

  @doc """
  Highlights all code block in an already generated HTML document.
  """
  def highlight(html) do
    Regex.replace(
      ~r/<pre><code(?:\s+class="(\w*)")?>([^<]*)<\/code><\/pre>/,
      html,
      &highlight_code_block(&1, &2, &3)
    )
  end

  defp highlight_code_block(full_block, lang, code) do
    case pick_language_and_lexer(lang) do
      {_language, nil, _opts} -> full_block
      {language, lexer, opts} -> render_code(language, lexer, opts, code)
    end
  end

  defp pick_language_and_lexer(""), do: {"text", nil, []}

  defp pick_language_and_lexer(lang) do
    case Makeup.Registry.fetch_lexer_by_name(lang) do
      {:ok, {lexer, opts}} -> {lang, lexer, opts}
      :error -> {lang, nil, []}
    end
  end

  defp render_code(lang, lexer, lexer_opts, code) do
    highlighted =
      code
      |> unescape_html()
      |> IO.iodata_to_binary()
      |> Makeup.highlight_inner_html(
        lexer: lexer,
        lexer_options: lexer_opts,
        formatter_options: [highlight_tag: "span"]
      )

    ~s(<pre><code class="makeup #{lang}">#{highlighted}</code></pre>)
  end

  entities = [{"&amp;", ?&}, {"&lt;", ?<}, {"&gt;", ?>}, {"&quot;", ?"}, {"&#39;", ?'}]

  for {encoded, decoded} <- entities do
    defp unescape_html(unquote(encoded) <> rest), do: [unquote(decoded) | unescape_html(rest)]
  end

  defp unescape_html(<<c, rest::binary>>), do: [c | unescape_html(rest)]
  defp unescape_html(<<>>), do: []
end
