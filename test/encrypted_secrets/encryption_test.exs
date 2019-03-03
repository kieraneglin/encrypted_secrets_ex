defmodule EncryptedSecretsTest.EncryptionTest do
  use ExUnit.Case
  alias EncryptedSecrets.Encryption, as: Encryption
  doctest EncryptedSecrets.Encryption

  test "generate 256 bit AES key as bytes" do
    aes_256_key = Encryption.generate_aes_key()

    assert(Kernel.is_bitstring(aes_256_key))
    assert(byte_size(aes_256_key) == 32)
    assert(bit_size(aes_256_key) == 256)
  end

  test "aes_gcm round-trip with 256 bit key" do
    aes_256_key = Encryption.generate_aes_key()
    clear_text = "a very secret message"

    {:ok, {init_vec, cipher_text}} = Encryption.encrypt(aes_256_key, clear_text)
    assert(clear_text != cipher_text)

    {:ok, decrypted_clear_text} = Encryption.decrypt(aes_256_key, init_vec, cipher_text)
    assert(decrypted_clear_text == clear_text)
  end
end
