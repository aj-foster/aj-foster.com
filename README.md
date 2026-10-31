# AJ Foster's website

This repository contains the source for [aj-foster.com](https://aj-foster.com/), a static
personal website built with Elixir and [Tableau](https://github.com/elixir-tools/tableau).
GitHub Actions builds the site on pushes to `main` and deploys the `site/` directory to
GitHub Pages.

## Publishing

After installing the Erlang and Elixir versions in `.tool-versions`:

- `mix site.gen` compiles the styles and generates the complete site in `site/`.
- `mix site.watch` starts Tableau's local development server and recompiles Sass on changes.

Pushing to `main` is still the publishing step; the existing GitHub Actions workflow runs
`mix site.gen` and deploys the generated output.

## Content

- Pages live in `pages/`; posts live in `posts/`.
- Both use Markdown with YAML front matter. Give each post a `date`, `preview`, and explicit
  `permalink` so old links remain stable if its title changes.
- Keep post permalinks in the existing `/year/slug/` format.
- Static files in `files/` and compiled assets are copied into the generated site.
- `mix site.gen` creates an RSS 2.0 feed at `/feed.xml` and a sitemap at `/sitemap.xml`.

The site uses Tableau's MDEx converter and Makeup for syntax highlighting. Styles are
compiled from `styles/app.scss` with Dart Sass.
