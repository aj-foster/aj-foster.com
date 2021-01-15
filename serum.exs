%{
  site_name: "AJ Foster",
  site_description: "TODO: Add site description",
  server_root: "https://aj-foster.com",
  base_url: "/",
  author: "AJ Foster",
  author_email: "public@aj-foster.com",
  posts_path: "",
  date_format: "{Mshort} {0D}, {YYYY}",
  plugins: [
    {Site.Subdirectory, []},
    {Serum.Plugins.LiveReloader, only: :dev},
    {Serum.Plugins.PreviewGenerator, args: [length: [chars: 150]]},
    {Site.Map, args: [for: [:pages, :posts]]}
  ]
}
