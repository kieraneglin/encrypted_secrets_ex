# EncryptedSecrets

EncryptedSecrets allows you to store your application's secrets inside your VCS to ease distribution and updating, à la [Rails 5.2 Encrypted Credentials][1]

This gives you the ability to easily distribute secrets among teammates/workstations (no more discrepancies between your team's secrets or having to update workstations after you change a secret!). It also reduces the need to manage environment variables in your remote servers.

[Documentation][2]

[View on hex.pm][3]

## Contents

- [Installation](#installation)
- [Security](#security)
  - [What algorithm does this use to encrypt files?](#what-algorithm-does-this-use-to-encrypt-files)
  - [How is the `master.key` generated?](#how-is-the-masterkey-generated)
  - [What is the secrets file?](#what-is-the-secrets-file)
  - [Why AES?](#why-aes)
  - [How did you implement the AES encryption?](#how-did-you-implement-the-aes-encryption)
  - [Anything else?](#anything-else)
- [Usage](#usage)
  - [Setup](#setup)
  - [Editing](#editing)
  - [Reading](#reading)
    - [Environment-specific secrets](#environment-specific-secrets)
  - [Use with Distillery](#use-with-distillery)
- [Contributing](#contributing)
- [License](#license)

## Installation

```elixir
def deps do
  [
    {:encrypted_secrets, "~> 0.2.0"}
  ]
end
```

## Security

### What algorithm does this use to encrypt files?

AES256

### How is the `master.key` generated?

Using `:crypto.strong_and_bytes/1` to generate a 256 bit key.
See `EncryptedSecrets.Encryption.generate_aes_key/0` for the implementation

### What is the secrets file?

It's a combination the initialization vector and YAML (encrypted using the aforementioned 256 bit key). The initialization vector is safe to include in the secrets file. The only file you need to keep secret is the `master.key`

### Why AES?

AES is the leading algorithm for encrypting and decrypting data. It is the de-factco algorithm as chosen by the NIST and it is absolutely battle-proven

### How did you implement the AES encryption?

I avoided "rolling my own" as much as possible. I delegate directly to the underlying Erlang functions for encryption and decryption. If you're interested, I strongly recommend you explore my implementation in `EncryptedSecrets.Encryption.encrypt/2` and `EncryptedSecrets.Encryption.decrypt/3`

### Anything else?

Yeah, a few things:

- If you're security minded, ensure you've reviewed the methods in `EncryptedSecrets.Encryption` and pull from this repo directly instead of hex.pm
- I am not a cryptographer. I am your average programmer who was missing a feature that I loved about Rails
- I mention it constantly, but _please_ ensure that the master key is to your `.gitignore`

## Usage

This package is intended for use with [Phoenix][4], but it can be used with any library you want.

### Setup

After installation, run this command in your project root to create a new key and secrets file:

```bash
mix EncryptedSecrets.Setup
```

This places two files in `priv/secrets/`. The task attempts to append the `master.key` file to your `.gitignore`, but you should confirm this! The `master.key` should never be placed in your VCS.

### Editing

To edit your secrets, you must ensure your `EDITOR` is in "wait" mode or else the files won't be saved after editing. This looks like `code --wait` for VSCode or `subl --wait` for Sublime Text. All together, the command to edit looks like this:

```bash
EDITOR='code --wait' mix EncryptedSecrets.Edit
```

If you don't have the `master.key` saved to your filesystem, you can explicitly specify the key by appending it when calling `EncryptedSecrets.Edit`. This is useful when you have specified your key as an environment variable.

The secrets file is YAML that supports all the usual datatypes, so nested maps and lists are fair game.

After editing, save and close the file to re-encrypt it. If there's an error (either within this package or your editor), the tempfile may not be deleted after editing. Always ensure that you don't accidentally commit this tempfile to your VCS.

### Reading

Once you've set up your credentials, you can access them with `EncryptedSecrets.read/2`. It will look for the files in `priv/secrets/` by default, so you don't need to specify any arguments unless you've moved the master key or secrets files. If you're deploying to production and you don't have a `master.key` file, save the key as an env variable and pass it as the first argument.

In the context of Phoenix, here's how you'd configure your application to access your secrets:

```elixir
# In AppName.Application#start/2

Application.put_env(
  :app_name,
  :secrets,
  EncryptedSecrets.read!()
)
```

These can then be used elsewhere as you would any other Application env:

```elixir
Application.get_env(:app_name, :secrets).foo # Where `foo` is a key in the secrets file
```

#### Environment-specific secrets

Currently, environment-specific secret files aren't supported. As a workaround, you can structure your YAML like so:

```yaml
dev:
  foo: "bar"
prod:
  foo: "baz"
```

Then, specify the default environment when using `Application.put_env`:

```elixir
# In AppName.Application#start/2

Application.put_env(
  :app_name,
  :secrets,
  EncryptedSecrets.read!()[Mix.env()]
)
```

### Use with Distillery

If you intend to package your releases with Distillery, you'll need to make a few changes:

```elixir
# In AppName.Application#start/2

# Alternatively, read key from an environment variable
master_key = File.read!(Application.app_dir(:app_name, "priv/secrets/master.key"))
secrets_file = Application.app_dir(:app_name, "priv/secrets/secrets.yml.enc")

# Optional, only required if you want easy access to environment-specific
# secrets. You must set `:env` in your `config/<env>.exs` files
current_env = Application.get_env(:app_name, :env)

Application.put_env(
  :app_name,
  :secrets,
  # Remove `[current_env]` unless you've followed the optional step above
  EncryptedSecrets.read!(master_key, secrets_file)[current_env]
)
```

## Contributing

This is my first Elixir project, so critique and contributions are welcome! If you have found an issue or want to request a feature, please create an issue or pull request as you see fit.

## License

MIT

[1]: https://www.engineyard.com/blog/rails-encrypted-credentials-on-rails-5.2
[2]: https://hexdocs.pm/encrypted_secrets
[3]: https://hex.pm/packages/encrypted_secrets
[4]: https://github.com/phoenixframework/phoenix
