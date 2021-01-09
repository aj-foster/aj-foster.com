defmodule Site.Subdirectory do
  @moduledoc """
  Serum Plugin that transforms post output paths and URLs so that instead of:

      /posts/yyyy-mm-dd-post-title.html

  we get:

      /yyyy/post-title/[index.html]

  This URL scheme aligns with previous iterations of the site, to which there may be external links.
  """
  @behaviour Serum.Plugin

  def name, do: "Subdirectory"
  def version, do: "1.0.0"
  def elixir, do: "~> 1.11"
  def serum, do: "~> 1.5"
  def description, do: "Make each post a subdirectory instead of a .html file"
  def implements, do: [processed_post: 2]

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
