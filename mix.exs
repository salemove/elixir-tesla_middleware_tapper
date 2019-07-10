defmodule TeslaMiddlewareTapper.MixProject do
  use Mix.Project

  def project do
    [
      app: :tesla_middleware_tapper,
      version: "0.1.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Tapper distributed request tracing integration for Tesla",
      docs: [
        main: "Tesla.Middleware.Tapper"
      ],
      dialyzer: [
        plt_add_apps: [:ex_unit],
        flags: [:error_handling, :race_conditions, :underspecs]
      ]
    ]
  end

  def package do
    [
      maintainers: ["SaleMove TechMovers"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/salemove/elixir-tesla_middleware_tapper"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.0"},
      {:tapper_plug, "~> 0.3"},
      {:ex_doc, "~> 0.18.0", only: :dev},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
