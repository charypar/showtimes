defmodule Showtimes.MixProject do
  use Mix.Project

  def project do
    [
      app: :showtimes,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Showtimes.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.4"},
      {:floki, "~> 0.20.0"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end
