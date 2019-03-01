defmodule EncryptedSecrets.WriteSecrets do
  def write_file(key, input_path, output_path) do
    read_input_file(input_path)
    |> encrypt_message(key)
    |> write_encrypted_file(output_path)
  end

  defp read_input_file(input_path) do
    case File.read(input_path) do
      {:ok, contents} -> contents
      {:error, message} -> throw("Unable to read input file: #{message}")
    end
  end

  defp encrypt_message(input_text, key) do
    {:ok, {_iv, cipher_text}} =
      Base.url_decode64!(key)
      |> ExCrypto.encrypt(input_text)

    Base.url_encode64(cipher_text)
  end

  defp write_encrypted_file(encrypted_string, output_path) do
    case File.open(output_path, [:write]) do
      {:ok, file} ->
        IO.binwrite(file, encrypted_string)
        File.close(file)
        {:ok, output_path}

      {:error, message} ->
        {:error, "Unable to write secrets to file '#{output_path}' (#{message})"}
    end
  end
end
