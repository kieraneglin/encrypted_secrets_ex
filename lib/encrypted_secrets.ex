defmodule EncryptedSecrets do
  alias EncryptedSecrets.ReadSecrets, as: ReadSecrets
  alias EncryptedSecrets.WriteSecrets, as: WriteSecrets

  def edit(key, secrets_path) do
    {:ok, tmp_filepath} = ReadSecrets.read_into_file(key, secrets_path)
    {_retval, 0} = System.cmd("code", ["--wait", tmp_filepath])
    {:ok, _path} = WriteSecrets.write_file(key, tmp_filepath, secrets_path)
    :ok = File.rm(tmp_filepath)
  end

  def read(key, secrets_path) do
    ReadSecrets.read_into_map(key, secrets_path)
  end

  def read!(key, secrets_path) do
    {:ok, secrets_map} = ReadSecrets.read_into_map(key, secrets_path)

    secrets_map
  end
end
