defmodule Site.Feed do
  @moduledoc """
  TODO
  """

  @behaviour Serum.Plugin

  serum_ver = Version.parse!(Mix.Project.config()[:version])
  serum_req = "~> #{serum_ver.major}.#{serum_ver.minor}"

  require EEx
  alias Serum.GlobalBindings
  alias Serum.Post

  def name, do: "Create a feed"
  def version, do: "1.2.0"
  def elixir, do: ">= 1.8.0"
  def serum, do: unquote(serum_req)

  def description do
    "Create a feed so users can subscribe"
  end

  def implements, do: [build_succeeded: 3]

  def build_succeeded(_src, dest, _args) do
    posts = get_posts()

    dest
    |> create_file(posts)
    |> Serum.File.write()
    |> case do
      {:ok, _} -> :ok
      {:error, _} = error -> error
    end
  end

  @spec get_posts :: [Post.t()]
  defp get_posts do
    GlobalBindings.get(:all_posts_with_content)
  end

  sitemap_path =
    File.cwd!()
    |> Path.join("includes")
    |> Path.join("feed.xml.eex")

  EEx.function_from_file(:defp, :sitemap_xml, sitemap_path, [
    :posts,
    :site
  ])

  @spec create_file(binary(), [Post.t()]) :: Serum.File.t()
  defp create_file(dest, posts) do
    %Serum.File{
      dest: Path.join(dest, "feed.xml"),
      out_data: sitemap_xml(posts, GlobalBindings.get(:site))
    }
  end
end
