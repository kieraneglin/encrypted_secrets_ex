defmodule EncryptedSecretsTest.MasterKeyTest do
  use ExUnit.Case
  alias EncryptedSecrets.MasterKey, as: MasterKey
  doctest EncryptedSecrets.MasterKey

  defmodule Create do
    use ExUnit.Case

    test "creates file then returns ok and filepath" do
      filepath = File.cwd!() <> "/test/tmp/master.key"

      try do
        {:ok, returned_filepath} = MasterKey.create(filepath)

        assert File.exists?(filepath)
        assert filepath == returned_filepath
      after
        File.rm(filepath)
      end
    end

    test "the created file contains random data" do
      filepath = File.cwd!() <> "/test/tmp/master.key"

      try do
        MasterKey.create(filepath)
        result_1 = File.read!(filepath)

        MasterKey.create(filepath)
        result_2 = File.read!(filepath)

        refute result_1 == result_2
      after
        File.rm(filepath)
      end
    end

    # The length of our base-16 encoded keys is 64 chars
    # NOTE: Is this a valid test? Why do
    test "the created file has 64 characters" do
      filepath = File.cwd!() <> "/test/tmp/master.key"

      try do
        MasterKey.create(filepath)
        result = File.read!(filepath)

        assert 64 == String.length(result)
      after
        File.rm(filepath)
      end
    end

    test "returns error when file cannot be created" do
      filepath = File.cwd!() <> "/test/not-real-path/master.key"
      {:error, error_message} = MasterKey.create(filepath)

      refute File.exists?(filepath)
      assert String.contains?(error_message, "Error writing master key")
    end

    test "returned error message includes the original FS error" do
      filepath = File.cwd!() <> "/test/not-real-path/master.key"
      {:error, error_message} = MasterKey.create(filepath)

      assert String.contains?(error_message, "enoent")
    end
  end
end
