defmodule I18n.Mixfile do
  use Mix.Project

  def project do
    [app: :i18n,
     version: "0.1.0",
     elixir: "~> 1.4",
     description: "A simple internationalization library",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end

  defp package do
    [
      name: :i18n,
      maintainers: ["Dennis Czombera"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/dczombera/i18n"},
      homepage_url: "https://dczombera.github.io/"
    ] 
  end
end
