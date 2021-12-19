Hello there.

This is the source code that generates my personal website, [aj-foster.com](https://aj-foster.com/).
It uses the following:

* Elixir, a functional programming language
* Serum, a static site generator written in Elixir
* GitHub Actions, a free continuous integration/deployment system
* GitHub Pages, a free hosting service for static websites
* GitHub Discussions, a free discussion platform

Because of these choices, the site itself is generated automatically when someone pushes to the
`main` branch — and hosted for free.

### Usage

This project includes two custom `mix` tasks for generating the site.
Assuming you have Elixir and Erlang installed already...

* `mix site.gen` will generate the site once and save the files
* `mix site.watch` will generate the site whenever a file is saved and auto-refresh the browser

### Items of Interest

Most of the site is pretty straightforward, however it includes a few plugins that adjust how
Serum generates files:

* `Site.Highlight` provides syntax highlighting for a subset of languages
* `Site.Subdirectory` modifies the output of pages and posts to support subdirectory navigation,
  e.g. `/about/`
* `Site.Feed` creates a custom Atom feed for posts on the site
* `Site.Map` creates a custom sitemap

The code in this repository is free to use (with no warranty).
Please share what you learn with others.
