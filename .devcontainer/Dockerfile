FROM hexpm/elixir:1.20.4-erlang-29.0.6-debian-bookworm-20261027

RUN apt-get update \
    && apt-get install --yes --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*
