defmodule EncryptedSecretsTest.HelpersTest do
  use ExUnit.Case
  alias EncryptedSecrets.Helpers, as: Helpers
  doctest EncryptedSecrets.Helpers

  defmodule ConvertMapKeys do
    use ExUnit.Case

    test "it converts maps with string keys into atom keys" do
      string_map = %{"foo" => %{"bar" => "baz"}}
      {:ok, atom_map} = Helpers.convert_map_keys({:ok, string_map})

      assert %{foo: %{bar: "baz"}} == atom_map
    end

    test "it passes errors straight through" do
      assert {:error, "No good"} == Helpers.convert_map_keys({:error, %{message: "No good"}})
    end
  end
end
