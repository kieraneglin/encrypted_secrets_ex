defmodule EncryptedSecrets.MasterKey do
  def create_master_key(filepath) do
    create_random_key()
    |> save_master_key(filepath)
  end

  defp create_random_key do
    :crypto.strong_rand_bytes(64) |> Base.encode16()
  end

  defp save_master_key(key, filepath) do
    case File.open(filepath, [:write]) do
      {:ok, file} ->
        IO.binwrite(file, key)
        File.close(file)
        {:ok, filepath}

      _ ->
        {:error, "Unable to write to file '#{filepath}'"}
    end
  end
end
