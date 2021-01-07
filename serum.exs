%{
  site_name: "AJ Foster",
  site_description: "TODO: Add site description",
  date_format: "{WDfull}, {D} {Mshort} {YYYY}",
  base_url: "/",
  author: "AJ Foster",
  author_email: "public@aj-foster.com",
  plugins: [
    {Serum.Plugins.LiveReloader, only: :dev}
  ]
}
