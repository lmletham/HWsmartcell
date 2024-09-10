defmodule Hwsmartcell.MixProject do
  use Mix.Project

  def project do
    [
      app: :hwsmartcell,
      version: "0.1.21",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A Livebook SmartCell for homework problems.",
      package: package(),
      source_url: "https://github.com/lmletham/HWsmartcell"
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
      {:kino, "~> 0.13.2"},
      {:earmark, "~> 1.4.47"},
      {:makeup, "~> 1.1"},
      {:makeup_elixir, "~> 0.7"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :hwsmartcell,
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lmletham/HWsmartcell"},
      maintainers: ["Lydia Letham"],
      files: ~w(lib mix.exs README.md LICENSE)
    ]
  end

end
