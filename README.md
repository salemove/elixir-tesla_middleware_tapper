# Tesla.Middleware.Tapper

[![Build Status](https://travis-ci.org/salemove/elixir-tesla_middleware_tapper.svg?branch=master)](https://travis-ci.org/salemove/elixir-tesla_middleware_tapper)
[![Hex.pm](https://img.shields.io/hexpm/v/tesla_middleware_tapper.svg)](https://hex.pm/packages/tesla_middleware_tapper)
[![Documentation](https://img.shields.io/badge/Documentation-online-green.svg)](http://hexdocs.pm/tesla_middleware_tapper)

[https://github.com/Financial-Times/tapper](Tapper) distributed request tracing integration for Tesla.

## Installation

The package can be installed by adding `tesla_middleware_tapper` to your list
of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tesla_middleware_tapper, "~> 0.1.0"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/tesla_middleware_tapper](https://hexdocs.pm/tesla_middleware_tapper).

## Usage

First add and configure [https://github.com/Financial-Times/tapper](tapper). After that you only need to add `plug Tesla.Middleware.Tapper` when you wish to trace outgoing http requests.

```elixir
defmodule CartService do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://cart.example.com"
  plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Tapper

  def fetch_items() do
    get("/items")
  end
end
```

## License

MIT License, Copyright (c) 2018 SaleMove
