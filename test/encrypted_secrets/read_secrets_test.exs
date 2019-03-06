defmodule EncryptedSecretsTest.ReadSecretsTest do
  use ExUnit.Case
  alias EncryptedSecrets.ReadSecrets, as: ReadSecrets
  doctest EncryptedSecrets.ReadSecrets

  defmodule ReadIntoMap do
    use ExUnit.Case

    @base_dir File.cwd!() <> "/test/files"
    @key_contents File.read!(File.cwd!() <> "/test/files/master.key")
    @enc_secrets @base_dir <> "/enc_secrets.yml"
    @enc_invalid @base_dir <> "/enc_invalid.yml"
    @enc_whitespace @base_dir <> "/enc_secrets_with_whitespace.yml"

    test "successfully reads encrypted secrets into map" do
      {:ok, secrets} = ReadSecrets.read_into_map(@key_contents, @enc_secrets)

      assert %{foo: %{bar: "baz"}} == secrets
    end

    test "successfully reads encrypted secrets into map, even with whitespace" do
      {:ok, secrets} = ReadSecrets.read_into_map(@key_contents, @enc_whitespace)

      assert %{foo: %{bar: "baz"}} == secrets
    end

    test "returns error if input file can't be read" do
      {:error, err} = ReadSecrets.read_into_map(@key_contents, @base_dir <> "/fake.yml")

      assert String.contains?(err, "fake.yml")
      assert String.contains?(err, "enoent")
    end

    test "returns error if input file can't be decrypted" do
      {:error, err} = ReadSecrets.read_into_map("fake key contents", @enc_secrets)

      assert String.contains?(err, "odd-length string")
    end

    test "returns error if decrypted yml can't be parsed" do
      {:error, err} = ReadSecrets.read_into_map(@key_contents, @enc_invalid)

      assert String.contains?(err, "malformed yaml")
    end
  end

  defmodule ReadIntoFile do
    use ExUnit.Case

    @base_dir File.cwd!() <> "/test/files"
    @key_contents File.read!(File.cwd!() <> "/test/files/master.key")
    @enc_secrets @base_dir <> "/enc_secrets.yml"

    test "successfully reads encrypted secrets into tempfile" do
      {:ok, filepath} = ReadSecrets.read_into_file(@key_contents, @enc_secrets)

      try do
        assert File.exists?(filepath)
        assert String.contains?(filepath, "secrets_tmp")
        assert String.contains?(File.read!(filepath), "foo")
      after
        File.rm(filepath)
      end
    end

    test "returns error if input file can't be read" do
      {:error, err} = ReadSecrets.read_into_file(@key_contents, @base_dir <> "/fake.yml")

      assert String.contains?(err, "fake.yml")
      assert String.contains?(err, "enoent")
    end

    test "returns error if input file can't be decrypted" do
      {:error, err} = ReadSecrets.read_into_file("fake key contents", @enc_secrets)

      assert String.contains?(err, "odd-length string")
    end
  end
end
