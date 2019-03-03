defmodule EncryptedSecrets.Encryption do
  @moduledoc """
    Provides methods for reading creating keys and encrypting/decrypting payloads
  """

  def generate_aes_key() do
    :crypto.strong_rand_bytes(32)
  end
end
