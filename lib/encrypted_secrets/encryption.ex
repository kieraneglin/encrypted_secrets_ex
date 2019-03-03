defmodule EncryptedSecrets.Encryption do
  @moduledoc """
    Provides methods for reading creating keys and encrypting/decrypting payloads
  """

  @aes_block_size 16

  @doc """
    Generates a 256 bit (32 byte) random key to be used as the master key

  ## Examples
      iex> binary_key = Encryption.generate_aes_key()
      iex> random_string = binary_key |> Base.encode16
      iex> String.length(random_string)
      64
  """
  def generate_aes_key() do
    :crypto.strong_rand_bytes(32)
  end

  @doc """
    Encrypts `clear_text` using the given key
  """
  def encrypt(key, clear_text) do
    initialization_vector = :crypto.strong_rand_bytes(16)
    payload = pad(clear_text, @aes_block_size)

    case :crypto.block_encrypt(:aes_cbc256, key, initialization_vector, payload) do
      {cipher_text, cipher_tag} ->
        {authentication_data, _clear_text} = payload
        {:ok, {authentication_data, {initialization_vector, cipher_text, cipher_tag}}}

      <<cipher_text::binary>> ->
        {:ok, {initialization_vector, cipher_text}}

      err ->
        {:error, err}
    end
  end

  defp pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> to_string(:string.chars(to_add, to_add))
  end
end
