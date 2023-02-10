---
title: Integrating Honeycomb.io with Elixir
layout: article
date: 2023-02-10
preview: Focused directions for integrating Honeycomb.io into your Elixir application with OpenTelemetry for observability.
category: Reflection
---

We recently tried [Honeycomb.io](https://honeycomb.io) at work for observability.
A lot has changed in this space over the past year, so it took some work to figure out the right way to do it.
This article documents the steps we took.

If you're looking for an explanation of observability and how it relates to Elixir, OpenTelemetry, etc., [Dave Lucia](https://davelucia.com/blog/observing-elixir-with-lightstep) has a great article for this.
It even covers some of the steps mentioned here.
In this article, we'll focus more on the code.
{:.callout .note}

## Set Up Honeycomb

To start, you will need to set up the following [in Honeycomb](https://honeycomb.io):

1. An **account**, if you don't already have one.
You can [sign up for free](https://ui.honeycomb.io/signup).

2. An **environment**.
Honeycomb creates a `test` environment by default.

3. An **API key**.
Honeycomb generates one by default, however you may want to generate an app-specific key instead.
This requires Team Owner permissions.
The API key should have "Send Events" permission as well as "Create Datasets" if you want it to implicitly create a new dataset for your app.

We will use the API key later when configuring the exporter.

## Install Dependencies

The following packages are required for all installations.

**Note**: It is important to list `:opentelemetry_exporter` first.
{:.callout .note}

```elixir
def deps do
  [
    # ...
    {:opentelemetry_exporter, "~> 1.0"},
    {:opentelemetry, "~> 1.0"},
    {:opentelemetry_api, "~> 1.0"}
  ]
end
```

These packages provide the base for collecting and exporting metrics.
Following are a few packages that help to instrument common Elixir libraries:

```elixir
def deps do
  [
    # ...
    {:opentelemetry_absinthe, "~> 1.0"},
    {:opentelemetry_cowboy, "~> 0.2.0"},
    {:opentelemetry_ecto, "~> 1.0"},
    {:opentelemetry_liveview, "~> 1.0"},
    {:opentelemetry_oban, "~> 1.0"},
    {:opentelemetry_phoenix, "~> 1.0"},
    {:opentelemetry_redix, "~> 0.1.0"},
    {:opentelemetry_tesla, "~> 1.0"}
  ]
end
```

Thanks to common naming conventions, you can search for other libraries [on Hex.pm](https://hex.pm/packages?search=opentelemetry&sort=recent_downloads).
If you can't find what you're looking for, you could use `:opentelemetry_telemetry` to hook into Erlang Telemetry events manually, or consider creating your own package for the community.

## Instrument Libraries

If you choose to install any of the additional packages above, most require a function call in the `start/1` function of your `Application` module to get set up.

```elixir
def start(_type, _args) do
  # ...
  OpentelemetryAbsinthe.setup()
  :opentelemetry_cowboy.setup()
  OpentelemetryEcto.setup([:my_app, :repo])
  OpentelemetryLiveView.setup()
  OpentelemetryOban.setup()
  OpentelemetryPhoenix.setup(adapter: :cowboy2)
  OpentelemetryRedix.setup()
end
```

<p>
Be sure to replace <code>:my_app</code> with the name of your OTP application.
For Phoenix <sup><a href="#footnote-1" id="footnote-1-source">1</a></sup>, you should also ensure you have a call to `Plug.Telemetry` in your Endpoint module:
</p>

```elixir
plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
```

And Tesla requires its instrumentation to be inserted as middleware. Of course, you should consult the documentation of each package for the latest installation instructions.

## Configuration

Now it's time to configure the various libraries.

### Release Configuration

First, we need to instruct OpenTelemetry how to run when running in a Mix Release.
(If you are not using Mix Releases for your application, you can skip this.)
Modify the release configuration:

```elixir
def project do
  [
    # ...
    releases: [
      my_app: [
        applications: [
          opentelemetry_exporter: :permanent,
          opentelemetry: :temporary
        ]
      ]
    ]
  ]
end
```

This accomplishes two things: first, it ensures `opentelemetry_exporter` and all of its dependencies start first, and second, it allows `opentelemetry` to crash without taking down the rest of the application.
The thinking is that an unobserved but running application is better than a crashed one.

### Resource Attribute Configuration

Next, we can inform OpenTelemetry about the environment in which our application runs.
This is most likely something we want to do using runtime configuration.
There are a number of [resource descriptors](https://opentelemetry.io/docs/reference/specification/resource/semantic_conventions/) available, which can be compiled into a single environment variable `OTEL_RESOURCE_ATTRIBUTES` **or** passed to the application environment:

```elixir
# config/runtime.exs

config :opentelemetry, resource: [
  service: [
    name: "api",
    namespace: "MyApp",
    # ...
  ],
  host: [
    name: System.fetch_env!("HOST"),
    # ...
  ]
]
```

For an example of compiling resource attributes into an environment variable, see [Dave Lucia's post](https://davelucia.com/blog/observing-elixir-with-lightstep).

### Tracer Configuration

Now we need to start connecting the various pieces of machinery we've defined.
By default, we can disable the export of trace information (for development and testing), and turn it on for production.

```elixir
# config/config.exs

config :opentelemetry,
  span_processor: :batch,
  traces_exporter: :none

# config/prod.exs

config :opentelemetry,
  traces_exporter: :otlp
```

### Sampling Configuration

Honeycomb's pricing is event-based, and they include the following note in [their documentation](https://docs.honeycomb.io/manage-data-volume/sampling/):

> If your service receives more than 1000 requests per second, sampling should be part of your observability journey.

With OpenTelemetry, we can configure a sampler that will both limit the number of events sent to Honeycomb and ensure that reported traces are complete.
This requires determining whether to sample a trace based on the root trace ID, and ensuring that all child spans follow the same decision.

Luckily, this functionality is built in.
In the following configuration, we use a parent-based sampler to ensure that all child spans match the sampling decision of their parent.
Then, for the root span, we use a trace ID-based ratio to keep a percentage of traces.

```elixir
config :opentelemetry,
  sampler: {:parent_based, %{root: {:trace_id_ratio_based, 0.01}}}
```

This `sampler` key can be added to an existing `opentelemetry` configuration block.
A float between `0.0` and `1.0` defines how many traces to keep: `0.0` for none, `0.1` for keeping 10% of all traces, and `1.0` for keeping all of them.

Samplers adhere to the `:otel_sampler` behaviour.
In the future, you can create your own sampler module that behaves differently depending on the root span's name, for example, or the outcome of the request.

### Honeycomb Configuration

Finally, we can tell our application about Honeycomb.
Because this involves an API key, we likely want to do this using runtime configuration:

```elixir
# config/runtime.exs

config :opentelemetry_exporter,
  otlp_protocol: :http_protobuf,
  otlp_endpoint: "https://api.honeycomb.io:443",
  otlp_headers: [
    {"x-honeycomb-team", System.fetch_env!("HONEYCOMB_API_KEY")},
    {"x-honeycomb-dataset", "MyApp"}
  ]
```

The next time the application starts in production, it will begin sending data to Honeycomb.

## Conclusion

OpenTelemetry is relatively new in the Erlang and Elixir ecosystem.
If you find yourself working with it, there's a great opportunity to contribute documentation and guides.

Good luck on your observability journey!

---

<ol class="my-8">
  <li id="footnote-1">
    <p class="mb-4">Although it is not currently clear from the documentation, the Phoenix library will automatically check for trace-related headers on incoming REST requests and respect that data. This means you can start collecting distributed traces across multiple services. (You will have to supply those headers to outgoing requests, when necessary.) <a href="#footnote-1-source">Back</a></p>
  </li>
</ol>
