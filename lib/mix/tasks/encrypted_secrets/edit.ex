defmodule Mix.Tasks.EncryptedSecrets.Edit do
  use Mix.Task

  @doc """
    "Decrypts and allows editing of secrets file.  Ensure your EDITOR is in 'wait' mode"

    Example: `EDITOR='code --wait' mix EncryptedSecrets.Edit`
  """
  def run(args) do
    case length(args) do
      0 ->
        case EncryptedSecrets.edit() do
          :ok -> nil
          {:error, err} -> raise err
        end

      _ ->
        [key | _tail] = args |> Enum.map(&String.trim/1)

        case EncryptedSecrets.edit(key) do
          :ok -> nil
          {:error, err} -> raise err
        end
    end
  end
end
