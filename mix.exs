defmodule Lushrlux.MixProject do
  use Mix.Project

  def project do
    [
      app: :lushrlux,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
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
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, "~> 0.15.3"}
    ]
  end

  defp aliases do
    [
      test: ["test --trace"]
    ]
  end
end
