defmodule EncryptedSecretsTest.WriteSecretsTask do
  use ExUnit.Case
  alias EncryptedSecrets.WriteSecrets, as: WriteSecrets
  doctest EncryptedSecrets.WriteSecrets

  defmodule WriteFile do
    use ExUnit.Case

    @base_dir File.cwd!() <> "/test/files"
    @key_contents File.read!(File.cwd!() <> "/test/files/master.key")
    @dec_secrets @base_dir <> "/dec_secrets.yml"

    test "successfully writes encrypted file" do
      {:ok, filepath} =
        WriteSecrets.write_file(
          @key_contents,
          @dec_secrets,
          @base_dir <> "/test.yml"
        )

      try do
        assert File.exists?(filepath)
        refute File.read!(@dec_secrets) == File.read!(filepath)
      after
        File.rm(filepath)
      end
    end

    test "returns error if input file can't be found" do
      {:error, err} =
        WriteSecrets.write_file(
          @key_contents,
          @base_dir <> "/fake.yml",
          @base_dir <> "/test.yml"
        )

      assert String.contains?(err, "fake.yml")
      assert String.contains?(err, "enoent")
    end

    test "raises error if encryption fails" do
      {:error, err} =
        WriteSecrets.write_file(
          "fake key contents",
          @dec_secrets,
          @base_dir <> "/test.yml"
        )

      assert String.contains?(err, "odd-length")
      refute File.exists?(@base_dir <> "/test.yml")
    end

    test "raises error if saving output file fails" do
      {:error, err} =
        WriteSecrets.write_file(
          @key_contents,
          @dec_secrets,
          @base_dir <> "/fake_dir/test.yml"
        )

      assert String.contains?(err, "Error writing secrets")
      assert String.contains?(err, "fake_dir/test.yml")
      assert String.contains?(err, "enoent")
      refute File.exists?(@base_dir <> "/fake_dir/test.yml")
    end
  end

  defmodule WriteBlankFile do
    use ExUnit.Case

    @base_dir File.cwd!() <> "/test/files"
    @key_contents File.read!(File.cwd!() <> "/test/files/master.key")

    test "successfully writes blank encrypted file" do
      {:ok, filepath} =
        WriteSecrets.write_blank_file(
          @key_contents,
          @base_dir <> "/blank_test.yml"
        )

      try do
        assert File.exists?(filepath)
        refute "" == File.read!(filepath)
      after
        File.rm(filepath)
      end
    end

    test "raises error if encryption fails" do
      {:error, err} =
        WriteSecrets.write_blank_file(
          "fake key contents",
          @base_dir <> "/test_blank.yml"
        )

      assert String.contains?(err, "odd-length")
      refute File.exists?(@base_dir <> "/test_blank.yml")
    end

    test "raises error if saving output file fails" do
      {:error, err} =
        WriteSecrets.write_blank_file(
          @key_contents,
          @base_dir <> "/fake_dir/test.yml"
        )

      assert String.contains?(err, "Error writing secrets")
      assert String.contains?(err, "fake_dir/test.yml")
      assert String.contains?(err, "enoent")
      refute File.exists?(@base_dir <> "/fake_dir/test.yml")
    end
  end
end
