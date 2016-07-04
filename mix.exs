defmodule HexWf.Mixfile do
  use Mix.Project

  def project do
    [app: :hex_wf,
     version: "0.0.2",
     elixir: "~> 1.3",
     escript: [main_module: HexWf],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :maxwell, :hackney]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:maxwell,  "~> 1.0.1"},
      {:poison,   "~> 2.2.0"},
      {:hackney,  "~> 1.6.0"}
    ]
  end
end
