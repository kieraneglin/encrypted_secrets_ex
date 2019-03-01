defmodule EncryptedSecrets.MasterKey do
  @moduledoc """
    Provides a method for creating and saving a random master encryption key
  """

  @doc """
    Creates a random key and saves it to the specified `filepath`

    Returns `{:ok, filepath} | {:error, error}`
  """
  def create(filepath) do
    create_random_key()
    |> save_master_key(filepath)
  end

  defp create_random_key do
    {:ok, key} = ExCrypto.generate_aes_key(:aes_256, :base64)

    key
  end

  defp save_master_key(key, filepath) do
    case File.open(filepath, [:write]) do
      {:ok, file} ->
        IO.binwrite(file, key)
        File.close(file)
        {:ok, filepath}

      {:error, message} ->
        {:error, "Unable to write master key to file '#{filepath}' (#{message})"}
    end
  end
end
