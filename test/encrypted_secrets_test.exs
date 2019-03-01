defmodule EncryptedSecretsTest do
  use ExUnit.Case
  doctest EncryptedSecrets

  test "greets the world" do
    assert EncryptedSecrets.hello() == :world
  end
end
