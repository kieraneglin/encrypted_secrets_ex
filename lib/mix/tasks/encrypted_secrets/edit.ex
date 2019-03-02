defmodule Mix.Tasks.EncryptedSecrets.Edit do
  use Mix.Task

  @shortdoc "Decrypts and allows editing of secrets file.  Ensure your EDITOR is in 'wait' mode"
  def run(_) do
    EncryptedSecrets.edit()
  end
end
