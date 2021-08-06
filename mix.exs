defmodule EncryptedSecrets.MixProject do
  use Mix.Project

  def project do
    [
      app: :encrypted_secrets,
      version: "0.3.0",
      elixir: "~> 1.5",
      description: description(),
      package: package(),
      source_url: "https://github.com/kieraneglin/encrypted_secrets_ex",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:yaml_elixir, "~> 2.5"}
    ]
  end

  defp description() do
    "A package that allows you to store encrypted application secrets in your VCS"
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{repo: "https://github.com/kieraneglin/encrypted_secrets_ex"}
    ]
  end
end
