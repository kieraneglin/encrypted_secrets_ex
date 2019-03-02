defmodule EncryptedSecrets do
  @moduledoc """
    Provides methods for setting up, editing, and reading of encrypted secrets
  """
  alias EncryptedSecrets.MasterKey, as: MasterKey
  alias EncryptedSecrets.ReadSecrets, as: ReadSecrets
  alias EncryptedSecrets.WriteSecrets, as: WriteSecrets

  @secrets_file_location "config/secrets.yml"
  @key_file_location "config/master.key"

  @doc """
    Creates a new key and secrets file, prompting you if the files already exist

    Returns `{:ok, secrets_path} | {:error, message}`
  """
  def setup(key_path \\ @key_file_location, secrets_path \\ @secrets_file_location) do
    success_message = "Operation completed! Make sure #{key_path} is in your .gitignore"

    # TODO `cond` felt cumbersome here, but if seems anti-elixir.  Investigate
    if File.exists?(key_path) || File.exists?(secrets_path) do
      IO.puts("This will remove your existing secrets and give you a new master key")
      IO.puts("Continue? (y/N)")
      input_string = IO.read(:stdio, :line) |> String.trim() |> String.downcase()

      cond do
        String.starts_with?(input_string, "y") ->
          setup!(key_path, secrets_path)
          IO.puts(success_message)
          {:ok, secrets_path}

        true ->
          {:error, "Operation aborted"}
      end
    else
      setup!(key_path, secrets_path)
      IO.puts(success_message)
    end
  end

  @doc """
    Creates a new key and secrets file, automatically overwriting files if they exist.
     Use with caution

    Returns `{:ok, secrets_path} | {:error, message}`
  """
  def setup!(key_path \\ @key_file_location, secrets_path \\ @secrets_file_location) do
    MasterKey.create(key_path)
    WriteSecrets.write_blank_file(File.read!(key_path), secrets_path)
  end

  @doc """
    Decrypts, opens, and saves secrets file.  Your EDITOR must be in "wait" mode.
     For example `EDITOR='code --wait'`

    Returns `:ok | {:error, message}`
  """
  def edit(key \\ File.read!(@key_file_location), secrets_path \\ @secrets_file_location) do
    ensure_editor_set()

    {:ok, tmp_filepath} = ReadSecrets.read_into_file(key, secrets_path)
    [editor | options] = String.split(System.get_env("EDITOR"), " ")
    {_retval, 0} = System.cmd(editor, options ++ [tmp_filepath])

    {:ok, _path} = WriteSecrets.write_file(key, tmp_filepath, secrets_path)
    File.rm(tmp_filepath)

    IO.puts("Secrets saved")
  end

  @doc """
    Decrypts and parses secrets file, returning it as a map

    Returns `{:ok, secrets_map} | {:error, message}`
  """
  def read(key \\ File.read!(@key_file_location), secrets_path \\ @secrets_file_location) do
    ReadSecrets.read_into_map(key, secrets_path)
  end

  @doc """
    Decrypts and parses secrets file, returning it as a map.
     Raises an exception if file can't be read

    Returns `{:ok, secrets_map}`
  """
  def read!(key \\ File.read!(@key_file_location), secrets_path \\ @secrets_file_location) do
    case ReadSecrets.read_into_map(key, secrets_path) do
      {:ok, secrets_map} -> secrets_map
      {:error, _err} -> raise "Could not read secrets file"
    end
  end

  defp ensure_editor_set() do
    case System.get_env("EDITOR") do
      nil -> raise "EDITOR must be set.  For example, EDITOR='code --wait' <command>"
      _ -> nil
    end
  end
end
