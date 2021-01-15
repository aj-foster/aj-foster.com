defmodule Site.Subdirectory do
  @moduledoc """
  Serum Plugin that transforms post output paths and URLs so that instead of:

      /about.html
      /posts/yyyy-mm-dd-post-title.html

  we get:

      /about/[index.html]
      /yyyy/post-title/[index.html]

  This URL scheme aligns with previous iterations of the site, to which there may be external links.
  """
  @behaviour Serum.Plugin

  def name, do: "Subdirectory"
  def version, do: "1.0.0"
  def elixir, do: "~> 1.11"
  def serum, do: "~> 1.5"
  def description, do: "Make each post a subdirectory instead of a .html file"
  def implements, do: [processed_page: 2, processed_post: 2]

  @doc """
  Alter the output file and URL of a processed page to use the desired scheme.
  """
  @spec processed_page(Serum.Page.t(), any) :: {:ok, Serum.Page.t()}
  def processed_page(page, _args) do
    case Regex.run(~r/\/(.*)\.md$/, page.file) do
      [_full_match, "index"] ->
        {:ok, page}

      [_full_match, _name] ->
        page =
          Map.update!(page, :output, &update_page_path/1)
          |> Map.update!(:url, &update_page_url/1)

        {:ok, page}

      _ ->
        {:ok, page}
    end
  end

  # Transform /path/to/page.html
  # to        /path/to/page/index.html
  #
  @spec update_page_path(String.t()) :: String.t()
  defp update_page_path(path) do
    first = Path.dirname(path)

    second =
      Path.basename(path)
      |> String.trim_trailing(".html")
      |> Path.join("/index.html")

    Path.join(first, second)
  end

  # Transform /page.md
  # to        /page/
  #
  @spec update_page_url(String.t()) :: String.t()
  defp update_page_url(path) do
    first = Path.dirname(path)

    second =
      Path.basename(path)
      |> String.trim_trailing(".html")

    Path.join(first, second) <> "/"
  end

  @doc """
  Alter the output file and URL of a processed post to use the desired scheme.
  """
  @spec processed_post(Serum.Post.t(), any) :: {:ok, Serum.Post.t()}
  def processed_post(post, _args) do
    {{year, _m, _d}, _time} = post.raw_date

    post =
      post
      |> Map.update!(:output, fn path -> update_path(path, year) end)
      |> Map.update!(:url, fn path -> update_url(path, year) end)

    {:ok, post}
  end

  # Transform /path/to/posts/yyyy-mm-dd-post-title.html
  # to        /path/to/posts/yyyy/post-title/index.html
  #
  @spec update_path(String.t(), integer) :: String.t()
  defp update_path(path, year) do
    first =
      Path.dirname(path)
      |> Path.join(to_string(year))

    second =
      Path.basename(path)
      |> String.replace(~r/^\d+-\d+-\d+-/, "")
      |> String.trim_trailing(".html")
      |> Path.join("/index.html")

    Path.join(first, second)
  end

  # Transform /posts/yyyy-mm-dd-post-title.html
  # to        /posts/yyyy/post-title/
  #
  @spec update_url(String.t(), integer) :: String.t()
  defp update_url(path, year) do
    first =
      Path.dirname(path)
      |> Path.join(to_string(year))

    second =
      Path.basename(path)
      |> String.replace(~r/^\d+-\d+-\d+-/, "")
      |> String.trim_trailing(".html")

    Path.join(first, second) <> "/"
  end
end
