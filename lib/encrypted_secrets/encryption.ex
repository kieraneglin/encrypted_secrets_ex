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
    Encrypts `clear_text` using the given `key`
  """
  def encrypt(key, clear_text) do
    init_vec = :crypto.strong_rand_bytes(16)
    payload = pad(clear_text, @aes_block_size)

    case :crypto.block_encrypt(:aes_cbc256, key, init_vec, payload) do
      {cipher_text, cipher_tag} ->
        {authentication_data, _clear_text} = payload
        {:ok, {authentication_data, {init_vec, cipher_text, cipher_tag}}}

      <<cipher_text::binary>> ->
        {:ok, {init_vec, cipher_text}}

      err ->
        {:error, err}
    end
  end

  @doc """
    Decrypts `cipher_text` using the given `key` and `init_vec`
  """
  def decrypt(key, init_vec, cipher_text) do
    case :crypto.block_decrypt(:aes_cbc256, key, init_vec, cipher_text) do
      :error -> {:error, :decrypt_failed}
      plain_text -> {:ok, unpad(plain_text)}
    end
  end

  defp pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> to_string(:string.chars(to_add, to_add))
  end

  defp unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end
end
