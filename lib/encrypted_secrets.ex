defmodule EncryptedSecrets do
  alias EncryptedSecrets.MasterKey, as: MasterKey
  alias EncryptedSecrets.ReadSecrets, as: ReadSecrets
  alias EncryptedSecrets.WriteSecrets, as: WriteSecrets

  def setup(key_path \\ "config/master.key", secrets_path \\ "config/secrets.yml") do
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
