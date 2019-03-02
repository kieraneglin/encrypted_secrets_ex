defmodule EncryptedSecrets.ReadSecrets do
  def read_file(key, input_path) do
    read_encrypted_file(input_path)
    |> unencrypt_file_contents(key)
    |> parse_yaml()
  end

  defp read_encrypted_file(input_path) do
    case File.read(input_path) do
      {:ok, contents} -> contents
      {:error, err} -> throw("Error reading '#{input_path}' (#{err})")
    end
  end

  defp unencrypt_file_contents(input_text, key) do
    [init_vec, cipher_text] =
      String.split(input_text, "|")
      |> Enum.map(&Base.url_decode64!/1)

    case ExCrypto.decrypt(Base.url_decode64!(key), init_vec, cipher_text) do
      {:ok, contents} -> contents
      {:error, err} -> throw("Error decrypting secrets (#{err})")
    end
  end

  defp parse_yaml(yaml_string) do
    YamlElixir.read_from_string(yaml_string)
  end
end
