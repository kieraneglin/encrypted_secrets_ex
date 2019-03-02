defmodule Mix.Tasks.EncryptedSecrets.Setup do
  use Mix.Task

  @shortdoc "Creates key and secrets file in config/"
  def run(_) do
    EncryptedSecrets.setup()
  end
end
