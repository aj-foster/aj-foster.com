import Config

config :dart_sass,
  version: "1.97.3",
  default: [
    args: ~w(styles/app.scss assets/css/app.css --no-source-map),
    cd: Path.expand("..", __DIR__)
  ]

config :tableau, :config,
  url: "https://aj-foster.com",
  out_dir: "site",
  include_dir: "files",
  converters: [md: Site.MarkdownConverter],
  markdown: [
    mdex: [
      extension: [table: true, header_id_prefix: "-", header_id_prefix_in_href: true],
      parse: [smart: true],
      render: [unsafe: true]
    ]
  ]

config :tableau, Tableau.PageExtension,
  enabled: true,
  dir: "pages",
  layout: Site.Layout

config :tableau, Tableau.PostExtension,
  enabled: true,
  dir: "posts",
  permalink: "/:year/:title/",
  layout: Site.PostLayout

config :tableau, Tableau.SitemapExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: true,
  feeds: [
    feed: [
      title: "AJ Foster",
      description: "Software, Math, and Robots"
    ]
  ]

config :tableau, :reloader,
  patterns: [
    ~r"pages/.*\.md",
    ~r"posts/.*\.md",
    ~r"templates/.*\.eex",
    ~r"includes/.*\.eex",
    ~r"styles/.*\.scss",
    ~r"assets/.*"
  ]

import_config "#{config_env()}.exs"
