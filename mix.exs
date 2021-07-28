defmodule Joi.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :joi,
      version: @version,
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Joi",
      source_url: "https://github.com/scottming/joi",
      docs: docs()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/joi/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "Data validation in elixir"
  end

  defp package() do
    [
      name: "joi",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/scottming/joi"}
    ]
  end

  defp docs() do
    [
      source_ref: "v#{@version}",
      main: "Joi",
      extras: ["README.md"]
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
      {:elixir_uuid, "~> 1.2"},
      {:decimal, "~> 2.0.0"},
      {:stream_data, "~> 0.5", only: [:test, :dev]},
      {:ex_doc, "~> 0.25.0", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:assertions, "~> 0.10", only: :test}
    ]
  end
end
