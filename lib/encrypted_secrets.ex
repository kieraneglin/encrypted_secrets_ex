defmodule EncryptedSecrets do
  alias EncryptedSecrets.MasterKey, as: MasterKey
  alias EncryptedSecrets.ReadSecrets, as: ReadSecrets
  alias EncryptedSecrets.WriteSecrets, as: WriteSecrets

  @secrets_file_location "config/secrets.yml"
  @key_file_location "config/master.key"

  def setup(key_path \\ @key_file_location, secrets_path \\ @secrets_file_location) do
    # TODO `cond` felt cumbersome here, but if seems anti-elixir.  Investigate
    if File.exists?(key_path) || File.exists?(secrets_path) do
      IO.puts("This will remove your existing secrets and give you a new master key")
      IO.puts("Continue? (y/N)")
      input_string = IO.read(:stdio, :line) |> String.trim() |> String.downcase()

      cond do
        String.starts_with?(input_string, "y") ->
          setup!(key_path, secrets_path)
          IO.puts("Operation completed! Make sure #{key_path} is in your .gitignore")
          {:ok, secrets_path}

        true ->
          {:error, "Operation aborted"}
      end
    else
      setup!(key_path, secrets_path)
    end
  end

  def setup!(key_path \\ @key_file_location, secrets_path \\ @secrets_file_location) do
    MasterKey.create(key_path)
    WriteSecrets.write_blank_file(File.read!(key_path), secrets_path)
  end

  def edit(key \\ File.read!(@key_file_location), secrets_path \\ @secrets_file_location) do
    {:ok, tmp_filepath} = ReadSecrets.read_into_file(key, secrets_path)

    [editor | options] = String.split(System.get_env("EDITOR"), " ")
    {_retval, 0} = System.cmd(editor, options ++ [tmp_filepath])

    {:ok, _path} = WriteSecrets.write_file(key, tmp_filepath, secrets_path)
    File.rm(tmp_filepath)
  end

  def read(key \\ File.read!(@key_file_location), secrets_path \\ @secrets_file_location) do
    ReadSecrets.read_into_map(key, secrets_path)
  end

  def read!(key \\ File.read!(@key_file_location), secrets_path \\ @secrets_file_location) do
    {:ok, secrets_map} = ReadSecrets.read_into_map(key, secrets_path)

    secrets_map
  end
end
