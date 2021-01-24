%{
  site_name: "AJ Foster",
  site_description: "Software, Math, and Robots",
  server_root: "https://aj-foster.com",
  base_url: "/",
  author: "AJ Foster",
  author_email: "public@aj-foster.com",
  posts_path: "",
  date_format: "{Mshort} {0D}, {YYYY}",
  plugins: [
    {Site.Highlight, []},
    {Site.Subdirectory, []},
    {Serum.Plugins.LiveReloader, only: :dev},
    {Serum.Plugins.PreviewGenerator, args: [length: [chars: 150]]},
    {Site.Feed, []},
    {Site.Map, args: [for: [:pages, :posts]]},
  ]
}
