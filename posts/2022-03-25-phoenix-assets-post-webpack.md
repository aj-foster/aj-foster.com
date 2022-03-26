---
title: Phoenix Static Assets in the Post-Webpack World
layout: article
date: 2022-03-25
preview: Creating a small package to help with copying static assets in a Phoenix application.
category: Reflection
---

Over the past few months, the Phoenix core team and the community around Phoenix have developed first-class support for [esbuild](https://github.com/phoenixframework/esbuild/) and [Tailwind CSS](https://github.com/phoenixframework/tailwind). Both projects offer an alternative to Webpack, the project used to manage static assets since Phoenix 1.4.

You may remember the upgrade to Webpack from Brunch, another build tool used in earlier versions of Phoenix. In that case, projects moved between relatively similar tools (at least, from an outside perspective) that offered similar functionality relative to the needs of a Phoenix application. The change to esbuild and Tailwind CSS is a bit different, however: it requires moving from one unified tool that compiles, bundles, and moves assets, to a collection of tools that cover those needs in a patchwork fashion.

## What is Covered

_(as of the time of writing)_

Many of the common tasks related to static assets are covered in this new paradigm:

* esbuild handles compiling and bundling JavaScript (and related) assets
  * It can also bundle CSS, depending on your setup
  * I use it for code splitting (although the feature is experimental)
  * It will also copy any assets referenced in the JavaScript
* Tailwind CSS works with a single CSS file out of the box
  * Using the `postcss-import` plugin can extend this to bundling multiple CSS files, which is especially helpful if you need to import stylesheets from dependencies
  * It will also copy any assets referenced in the CSS
  * esbuild could help with bundling CSS if you invest in a multi-step build process
  * Both Tailwind and esbuild can minify the output

With careful configuration, these two standalone CLI tools can cover most use-cases.

## What isn't Covered

In one particular application I work on, there's a need that wasn't covered in this new way of working: **copying static assets that aren't CSS or JavaScript**. Images, favicons, `robots.txt` — in this project, these assets still live in `assets/static/`, and they need to end up in `priv/static/` with the bundled JavaScript and CSS. But how do they get there?

> **Important Note**: The best answer for your application might be to just move these files to `priv/static/`. That's where they live in newly generated Phoenix applications. If you don't have a reason for `priv/static/` to be completely ignored by version control, consider this option.

In this app, however, keeping files in `priv/static/` isn't the best idea. So something needs to get them there — continuously during development, and once during asset deployment.

## My Solution

I tried to bend the Tailwind and esbuild standalone CLI tools to do the work for me. There are certainly situations in which this could work, depending on your setup. For me, it didn't feel right to introduce additional imports in my JavaScript just for esbuild to include a file in its process. Similarly, it didn't make sense to reference the assets in my CSS.

So, I made [something to solve the problem](https://github.com/aj-foster/phx_copy).

**Phoenix Copy** is a small Hex package that operates just like the esbuild and Tailwind standalone tools. Instead of running an external CLI command, however, it uses the `File` module to manage files. It has two modes:

1. "Run once" to copy files during asset deployment, and
2. "Watch" to copy files continuously during development.

My goal in building it was this:

```elixir
# config/dev.exs

config :my_app, MyAppWeb.Endpoint,
  http: [port: 4000],
  # ...
  watchers: [
    asset_copy: {Phoenix.Copy, :watch, [:default]},
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# mix.exs

defp aliases do
  [
    "assets.deploy": [
      "phx.copy default",
      "esbuild default --minify",
      "tailwind default --minify",
      "phx.digest"
    ],
    # ...
  ]
end
```

Whenever Phoenix calls upon esbuild or Tailwind to manage assets, it can also call upon Phoenix Copy to copy _everything else_ not otherwise covered.

## Construction

Both of the Phoenix-specific esbuild and Tailwind packages use configuration **profiles**. These allow you to have multiple, named configurations. I love this, because it doesn't assume that your project has a single bundle of any given asset. I followed this pattern with Phoenix Copy as well: although my project only needs to move files from `assets/static/` to `priv/static`, others might need more.

```elixir
config :phoenix_copy,
  default: [
    source: Path.expand("../assets/static/", __DIR__),
    destination: Path.expand("../priv/static/", __DIR__)
  ]
```

So far, the configuration is pretty simple: source and destination pairs. Using this information, the package offers two entrypoints:

* `run/1`, which is used by `mix phx.copy`, takes the name of a configuration profile and performs a one-time copy of all the files
* `watch/1` takes the name of a configuration profile, runs an initial copy of all files, and then watches for changes in the source directory (copying individual files as needed).

The watcher proved interesting to build, because the Phoenix Endpoint watcher configuration expects the function to block execution indefinitely. In Elixir we're pretty comfortable spawning tasks and allowing them to run concurrently; spawning a file watcher and listening for messages **without** a dedicated process is more interesting.

In early release candidates, the watcher module was a `GenServer` that managed the file watcher process and listened to its messages. `watch/1` would start and link this GenServer process in a task and call `Task.await(task, :infinity)`. It wasn't pretty, but it worked.

Of course, this setup proved hard to test. The indirection of (a) starting a process that (b) starts the file watcher made things slightly more complicated than necessary. _So_, I thought, _let's remove the middleman_.

For the `0.1.0` release, the watcher startup looks like this:

```elixir
def watch(source, destination) do
  Logger.info("Starting Phoenix.Copy file watcher...")
  {:ok, watcher_pid} = FileSystem.start_link(dirs: [source])
  FileSystem.subscribe(watcher_pid)

  handle_messages(source, destination, watcher_pid)
end
```

No more intermediate GenServer. Just start the filesystem watcher and then call `handle_messages/3`, which looks like this:

```elixir
defp handle_messages(source, destination, watcher_pid) do
  receive do
    {:file_event, _watcher_pid, {path, events}} ->
      # Copy file...
      handle_messages(source, destination, watcher_pid)

    {:file_event, _watcher_pid, :stop} ->
      # Return, presumably towards the termination of this process.
      nil
  end
end
```

Manually calling `receive/1` seems so rare in web applications, because we have amazing abstractions like the GenServer module. Sometimes, however — like when you need to block the execution of a calling process while listening for messages — it's a great tool.

There are still troubles when it comes to testing, and plenty of edge cases I've yet to encounter. However, I'm satisfied with the project's performance with my small sample size of one.

## Conclusion

Phoenix, Elixir, Tailwind CSS, Alpine.js, and LiveView (PETAL) is an increasingly compelling story for developing real-time web applications. I'm delighted to see the Phoenix team embrace these new counterparts with first-class packages wrapping the esbuild and Tailwind CLI tools. For most projects, it's all you need to have a comprehensive asset pipeline.

For my project, I needed a little more. [Phoenix Copy](https://github.com/aj-foster/phx_copy) isn't for everyone, but it could help you.
