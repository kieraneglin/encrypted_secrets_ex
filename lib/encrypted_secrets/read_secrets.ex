defmodule EncryptedSecrets.ReadSecrets do
  @moduledoc """
    Provides methods for reading encrypted secrets into unencrypted maps or files
  """

  alias EncryptedSecrets.Helpers, as: Helpers
  alias EncryptedSecrets.Encryption, as: Encryption

  @cleaner_script_path Path.join([:code.priv_dir(:encrypted_secrets), "tmp_file_cleaner.sh"])

  @doc """
    Reads encrypted secrets file at `input_path` using `key`, returning a map

    Returns `{:ok, secrets_map} | {:error, message}`
  """
  def read_into_map(key, input_path) do
    read_encrypted_file(input_path)
    |> unencrypt_file_contents(key)
    |> parse_yaml()
    |> Helpers.convert_map_keys()
  rescue
    e in RuntimeError -> {:error, e.message}
    e in ArgumentError -> {:error, e.message}
  end

  @doc """
    Reads encrypted secrets file at `input_path` using `key`,
     saving results in a tempfile

    Returns `{:ok, temp_filepath} | {:error, message}`
  """
  def read_into_file(key, input_path) do
    read_encrypted_file(input_path)
    |> unencrypt_file_contents(key)
    |> write_temp_file(input_path)
  rescue
    e in RuntimeError -> {:error, e.message}
    e in ArgumentError -> {:error, e.message}
  end

  defp read_encrypted_file(input_path) do
    case File.read(input_path) do
      {:ok, contents} -> contents
      {:error, err} -> raise "Error reading '#{input_path}' (#{err})"
    end
  end

  defp unencrypt_file_contents(input_text, key) do
    key_as_binary =
      String.trim(key)
      |> Base.decode16!()

    [init_vec, cipher_text] =
      String.split(input_text, "|")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&Base.decode16!/1)

    case Encryption.decrypt(key_as_binary, init_vec, cipher_text) do
      {:ok, contents} -> contents
      {:error, err} -> raise "Error decrypting secrets (#{err})"
    end
  end

  defp parse_yaml(yaml_string) do
    YamlElixir.read_from_string(yaml_string)
  end

  defp write_temp_file(yaml_string, input_path) do
    working_directory = Path.dirname(input_path)
    # Honestly, I'm not sure why Rails appends a random string to the tmp files.
    # Maybe to avoid file collisions in a really dumb way?  Who knows.  Anyway, I'm doing it
    random_file_suffix = :crypto.strong_rand_bytes(8) |> Base.encode16()
    filename = "#{working_directory}/secrets_tmp_#{random_file_suffix}.yml"

    if match?({:unix, _}, :os.type()) do
      Task.async(fn -> System.cmd(@cleaner_script_path, [filename]) end)
    end

    case File.write(filename, yaml_string) do
      :ok -> {:ok, filename}
      {:error, err} -> {:error, "Error creating tempfile (#{err})"}
    end
  end
end
