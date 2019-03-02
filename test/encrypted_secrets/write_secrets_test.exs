defmodule EncryptedSecretsTest.WriteSecretsTask do
  use ExUnit.Case
  alias EncryptedSecrets.WriteSecrets, as: WriteSecrets
  doctest EncryptedSecrets.WriteSecrets

  defmodule WriteFile do
    use ExUnit.Case

    @base_dir File.cwd!() <> "/test/files"
    @key_contents File.read!(File.cwd!() <> "/test/files/master.key")
    @dec_secrets @base_dir <> "/dec_secrets.yml"
    @enc_secrets @base_dir <> "/enc_secrets.yml"

    test "successfully writes encrypted file" do
      WriteSecrets.write_file(@key_contents, @dec_secrets, @base_dir <> "/test.yml")
    end
  end
end
