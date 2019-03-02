defmodule Mix.Tasks.EncryptedSecrets.Edit do
  use Mix.Task

  @doc """
    "Decrypts and allows editing of secrets file.  Ensure your EDITOR is in 'wait' mode"

    Example: `EDITOR='code --wait' mix encrypted_secrets.edit`
  """
  def run(_) do
    case EncryptedSecrets.edit() do
      :ok -> nil
      {:error, err} -> raise err
    end
  end
end
