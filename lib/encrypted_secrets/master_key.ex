defmodule EncryptedSecrets.MasterKey do
  @moduledoc """
    Provides a method for creating and saving a random master encryption key
  """

  alias EncryptedSecrets.Encryption, as: Encryption

  @doc """
    Creates a random key and saves it to the specified `filepath`

    Returns `{:ok, filepath} | {:error, error}`
  """
  def create(output_path) do
    create_random_key()
    |> save_master_key(output_path)
  catch
    _, err -> {:error, err}
  end

  defp create_random_key do
    Encryption.generate_aes_key()
    |> Base.encode16()
  end

  defp save_master_key(key, output_path) do
    case File.write(output_path, key) do
      :ok -> {:ok, output_path}
      {:error, err} -> {:error, "Error writing master key to '#{output_path}' (#{err})"}
    end
  end
end
