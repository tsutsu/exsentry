defmodule ExSentry.Mixfile do
  use Mix.Project

  def project do
    [app: :exsentry,
     version: "0.7.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test
     ],
     description: "ExSentry is a client for the Sentry error reporting platform.",
     package: [
       maintainers: ["pete gamache", "Appcues"],
       licenses: ["MIT"],
       links: %{GitHub: "https://github.com/appcues/exsentry"}
     ],
     docs: [main: ExSentry],
     deps: deps]
  end

  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [
        :logger,
        :fuzzyurl,
        :uuid,
        :hackney,
        :poison,
        :plug,
      ],
      mod: {ExSentry, []}]
  end

  defp deps do
    [
      {:fuzzyurl, "~> 0.9 or ~> 1.0"},
      {:uuid, "~> 1.1"},
      {:hackney, "~> 1.6"},
      {:poison, "~> 1.5 or ~> 2.0 or ~> 3.0"},
      {:plug, "~> 1.2"},

      {:ex_spec, "~> 2.0", only: :test},
      {:mock, "~> 0.2.0", only: :test},
      {:excoveralls, "~> 0.5.7", only: :test},

      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14.3", only: :dev},
    ]
  end
end
