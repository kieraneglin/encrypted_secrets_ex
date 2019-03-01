defmodule EncryptedSecrets.WriteSecrets do
  def write_file(key, input_path, output_path) do
    read_input_file(input_path)
    |> encrypt_message(key)
    |> write_encrypted_file(output_path)
  end

  defp read_input_file(input_path) do
    case File.read(input_path) do
      {:ok, contents} -> contents
      {:error, err} -> throw("Error reading '#{input_path}' (#{err})")
    end
  end

  defp encrypt_message(input_text, key) do
    {:ok, {_iv, cipher_text}} =
      Base.url_decode64!(key)
      |> ExCrypto.encrypt(input_text)

    Base.url_encode64(cipher_text)
  end

  defp write_encrypted_file(encrypted_string, output_path) do
    case File.write(output_path, encrypted_string) do
      :ok -> {:ok, output_path}
      {:error, err} -> throw("Error writing secrets to '#{output_path}' (#{err})")
    end
  end
end
