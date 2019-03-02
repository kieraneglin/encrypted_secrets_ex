defmodule EncryptedSecrets do
  alias EncryptedSecrets.MasterKey, as: MasterKey
  alias EncryptedSecrets.ReadSecrets, as: ReadSecrets
  alias EncryptedSecrets.WriteSecrets, as: WriteSecrets

  def setup(key_path \\ "config/master.key", secrets_path \\ "config/secrets.yml") do
    # TODO `cond` felt cumbersome here, but if seems anti-elixir.  Investigate
    if File.exists?(key_path) || File.exists?(secrets_path) do
      IO.puts("This will remove your existing secrets and give you a new master key")
      IO.puts("Continue? (y/N)")
      input_string = IO.read(:stdio, :line) |> String.trim() |> String.downcase()

      cond do
        String.starts_with?(input_string, "y") ->
          setup!(key_path, secrets_path)
          IO.puts("Operation completed! Make sure #{key_path} is in your .gitignore")

        true ->
          {:error, "Operation aborted"}
      end
    else
      setup!(key_path, secrets_path)
    end
  end

  def setup!(key_path \\ "config/master.key", secrets_path \\ "config/secrets.yml") do
    MasterKey.create(key_path)
    WriteSecrets.write_blank_file(File.read!(key_path), secrets_path)
  end

  def edit(key, secrets_path \\ "config/secrets.yml") do
    {:ok, tmp_filepath} = ReadSecrets.read_into_file(key, secrets_path)
    {_retval, 0} = System.cmd("code", ["--wait", tmp_filepath])
    {:ok, _path} = WriteSecrets.write_file(key, tmp_filepath, secrets_path)
    :ok = File.rm(tmp_filepath)
  end

  def read(key, secrets_path \\ "config/secrets.yml") do
    ReadSecrets.read_into_map(key, secrets_path)
  end

  def read!(key, secrets_path \\ "config/secrets.yml") do
    {:ok, secrets_map} = ReadSecrets.read_into_map(key, secrets_path)

    secrets_map
  end
end
