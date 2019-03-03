# EncryptedSecrets

EncryptedSecrets allows you to store your application's secrets inside your VCS to ease distribution and updating, à la [Rails 5.2 Encrypted Credentials][1]

[Documentation][2]

[View on hex.pm][3]

## Installation

```elixir
def deps do
  [
    {:encrypted_secrets, "~> 0.1.0"}
  ]
end
```

## Usage

This package is intended for use with [Phoenix][4], but it can be used with any library you want.

### Setup

After installation, run this command in your project root to create a new key and secrets file:

```bash
mix EncryptedSecrets.setup
```

This places two files in `config/secrets/`. Don't forget to put the `master.key` in your `.gitignore`!

### Editing

To edit your secrets, you must ensure your `EDITOR` is in "wait" mode or else the files won't be saved after editing. This looks like `code --wait` for VSCode or `subl --wait` for Sublime Text. All together, the command to edit looks like this:

```bash
EDITOR='code --wait' mix EncryptedSecrets.edit
```

The secrets file is YAML that supports all the usual datatypes, so nested maps and lists are fair game.

After editing, save and close the file to re-encrypt it. If there's an error (either within this package or your editor), the tempfile may not be deleted after editing. Always ensure that you don't accidentally commit this tempfile to your VCS.

### Reading

Once you've set up your credentials, you can access them with `EncryptedSecrets.read/2`. It will look for the files in `config/secrets/` by default, so you don't need to specify any arguments unless you've moved the master key or secrets files. If you're deploying to production and you don't have a `master.key` file, save the key as an env variable and pass it as the first argument.

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

## Contributing

This is my first Elixir project, so critique and contributions are welcome! If you have found an issue or want to request a feature, please create an issue or pull request as you see fit.

## License

MIT

[1]: https://www.engineyard.com/blog/rails-encrypted-credentials-on-rails-5.2
[2]: https://hexdocs.pm/encrypted_secrets
[3]: https://hex.pm/packages/encrypted_secrets
[4]: https://github.com/phoenixframework/phoenix
