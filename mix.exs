defmodule Windicss.MixProject do
  use Mix.Project

  @version "0.2.0-dev"
  @source_url "https://github.com/windicss/windicss"

  def project do
    [
      app: :windicss,
      version: @version,
      elixir: "~> 1.11",
      deps: deps(),
      description: "Mix tasks for installing and invoking windicss",
      package: [
        links: %{
          "GitHub" => @source_url,
          "windicss" => "https://windicss.org"
        },
        licenses: ["MIT"]
      ],
      docs: [
        main: "Windicss",
        source_url: @source_url,
        source_ref: "v#{@version}",
        extras: ["CHANGELOG.md"]
      ],
      aliases: [test: ["windicss.install --if-missing", "test"]]
    ]
  end

  def application do
    [
      extra_applications: [:logger, inets: :optional, ssl: :optional],
      mod: {Windicss, []},
      env: [default: []]
    ]
  end

  defp deps do
    [
      {:castore, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end
end
