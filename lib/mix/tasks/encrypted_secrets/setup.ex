defmodule Mix.Tasks.EncryptedSecrets.Setup do
  use Mix.Task

  @doc """
    "Creates key and secrets file in config/"
  """
  def run(_) do
    case EncryptedSecrets.setup() do
      {:ok, _secrets_path} -> nil
      {:error, err} -> raise err
    end
  end
end
