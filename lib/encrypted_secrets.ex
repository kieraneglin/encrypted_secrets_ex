defmodule EncryptedSecrets do
  @moduledoc """
    Provides methods for setting up, editing, and reading of encrypted secrets
  """
  alias EncryptedSecrets.Helpers, as: Helpers
  alias EncryptedSecrets.MasterKey, as: MasterKey
  alias EncryptedSecrets.ReadSecrets, as: ReadSecrets
  alias EncryptedSecrets.WriteSecrets, as: WriteSecrets

  @base_directory "priv/secrets"
  @secrets_file_location @base_directory <> "/secrets.yml.enc"
  @key_file_location @base_directory <> "/master.key"
  @editor_args_regex ~r/ (-\w{2,}|-\w\s+"(?:[^"\\]*(?:\\.[^"\\]*)*)"|-\w\s+'(?:[^'\\]*(?:\\.[^'\\]*)*)'|--\w+="(?:[^"\\]*(?:\\.[^"\\]*)*)"|--\w+='(?:[^'\\]*(?:\\.[^'\\]*)*)'|--\w+=[^\s]+|-\w)/

  @doc """
    Creates a new key and secrets file, prompting you if the files already exist

    Returns `{:ok, secrets_path} | {:error, message}`
  """
  def setup(key_path \\ @key_file_location, secrets_path \\ @secrets_file_location) do
    success_message = "Operation completed! Make sure #{key_path} is in your .gitignore"

    if File.exists?(key_path) || File.exists?(secrets_path) do
      IO.puts("This will remove your existing secrets and give you a new master key")
      IO.puts("Continue? (y/N)")
      input_string = IO.read(:stdio, :line) |> String.trim() |> String.downcase()

      cond do
        String.starts_with?(input_string, "y") ->
          setup_and_append_to_gitignore(key_path, secrets_path, success_message)

        true ->
          {:error, "Operation aborted"}
      end
    else
      setup_and_append_to_gitignore(key_path, secrets_path, success_message)
    end
  end

  @doc """
    Creates a new key and secrets file, automatically overwriting files if they exist.
     Use with caution

    Returns `{:ok, secrets_path} | {:error, message}`
  """
  def setup!(key_path \\ @key_file_location, secrets_path \\ @secrets_file_location) do
    File.mkdir_p!(@base_directory)
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

    case ReadSecrets.read_into_file(key, secrets_path) do
      {:ok, tmp_filepath} ->
        [editor | options] = String.split(
          System.get_env("EDITOR"),
          @editor_args_regex,
          include_captures: true,
          trim: true
        )
        options = Enum.map(options, &String.trim/1)
        {_retval, 0} = System.cmd(editor, options ++ [tmp_filepath])

        case WriteSecrets.write_file(key, tmp_filepath, secrets_path) do
          {:ok, _path} ->
            File.rm(tmp_filepath)
            IO.puts("Secrets saved")

          {:error, err} ->
            {:error, err}
        end

      {:error, err} ->
        {:error, err}
    end
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

  defp setup_and_append_to_gitignore(key_path, secrets_path, success_message) do
    setup!(key_path, secrets_path)
    Helpers.append_to_gitignore(key_path)
    IO.puts(success_message)

    {:ok, secrets_path}
  end

  defp ensure_editor_set() do
    case System.get_env("EDITOR") do
      nil -> raise "EDITOR must be set.  For example, EDITOR='code --wait' <command>"
      _ -> nil
    end
  end
end
