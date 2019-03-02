defmodule EncryptedSecrets.MixProject do
  use Mix.Project

  def project do
    [
      app: :encrypted_secrets,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.12"},
      {:yaml_elixir, "~> 2.1.0"},
      {:ex_crypto, "~> 0.10.0"}
    ]
  end
end
