defmodule Satori.Mixfile do
  use Mix.Project

  def project do
    [app: :satori,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :ssl, :crypto, :websocket_client],
     mod: {Satori.Application, []}]
  end

  defp deps do
    [
      {:websocket_client, "~> 1.2"},
      {:poison, "~> 3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  def description do
    """
    Websocket Client for Satori (https://www.satori.com)
    """
  end

  def package do
    [
      name: :satori,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Christopher Steven Coté"],
      licenses: ["Apache License 2.0"],
      links: %{"GitHub" => "https://github.com/NationalAssociationOfRealtors/satori",
          "Docs" => "https://github.com/NationalAssociationOfRealtors/satori"}
    ]
  end
end
