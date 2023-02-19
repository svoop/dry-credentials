[![Version](https://img.shields.io/gem/v/dry-credentials.svg?style=flat)](https://rubygems.org/gems/dry-credentials)
[![Tests](https://img.shields.io/github/actions/workflow/status/svoop/dry-credentials/test.yml?style=flat&label=tests)](https://github.com/svoop/dry-credentials/actions?workflow=Test)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/svoop/dry-credentials.svg?style=flat)](https://codeclimate.com/github/svoop/dry-credentials/)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

# Dry::Credentials

Manage and deploy secrets (access keys, API tokens etc) in encrypted files which can safely be committed to the code repository. To decrypt and and use them, only one environment variable containing the corresponding key is required.

While similar to ActiveSupport::EncryptedConfiguration, this lightweight implementation introduces as few dependencies as necessary.

* [Homepage](https://github.com/svoop/dry-credentials)
* [API](https://www.rubydoc.info/gems/dry-credentials)
* Author: [Sven Schwyn - Bitcetera](https://bitcetera.com)

## Install

### Security

This gem is [cryptographically signed](https://guides.rubygems.org/security/#using-gems) in order to assure it hasn't been tampered with. Unless already done, please add the author's public key as a trusted certificate now:

```
gem cert --add <(curl -Ls https://raw.github.com/svoop/dry-credentials/main/certs/svoop.pem)
```

### Bundler

Add the following to the <tt>Gemfile</tt> or <tt>gems.rb</tt> of your [Bundler](https://bundler.io) powered Ruby project:

```ruby
gem 'dry-credentials'
```

And then install the bundle:

```
bundle install --trust-policy MediumSecurity
```

## Usage

Extend any class with `Dry::Credentials` to use the [default settings](#defaults):

```ruby
class App
  extend Dry::Credentials
end
```

The `credentials` macro allows you to tweak the settings:

```ruby
class App
  extend Dry::Credentials

  credentials do
    env "sandbox"
    dir "/path/to/credentials"
  end
end
```

Now initialize the credentials for this `env`:

```ruby
App.credentials.edit!
```

And it creates `/path/to/credentials/sandbox.yaml.enc` (where the encrypted credentials are stored) and opens this file using your favourite editor as per the `EDITOR` environment variable.

For the sake of this example, let's assume you paste the following credentials:

```yml
otp:
  secret_key: ZcikLNiUQoqOo594oH2eqw04HPclhjkpgvpBik/40oU=
  salt: 583506a49c71724a9f085bf2e70362df9d973f08d6575191cab6a177dfb872c6
  meta:
    realm: main
```

When you close the editor, the credentials are encrypted and stored. This first time only, the key to encrypt and decrypt is printed to STDOUT:

```
SANDBOX_CREDENTIALS_KEY=47de05424afadcfcbb4960135ae4592b
```

To decrypt the credentials and use them in your app, you have to set just this one environment variable containing the key, in this case:

```sh
export SANDBOX_CREDENTIALS_KEY=47de05424afadcfcbb4960135ae4592b
```

With this in place, you can use the decrypted credentials anywhere in your app:

```ruby
App.credentials.otp.secret_key
# => "ZcikLNiUQoqOo594oH2eqw04HPclhjkpgvpBik/40oU="

App.credentials.otp.meta.name
# => "main"
```

## Environments

Credentials are isolated into environments which most likely will, but don't necessarily have to align with the environments of the app framework you're using.

By default, the current environment is read from `RACK_ENV` which encourages you to use separate keys e.g. for `production`, `development` and so forth.

⚠️ For safety reasons, don't share the same key across multiple environments!

## Edit Credentials

This gem does not provide any CLI tools to edit the credentials. You should integrate it into your app instead e.g. with a Rake task or an extension to the CLI tool of the app framework you're using.

You can explicitly pass the environment to edit:

```ruby
App.credentials.edit! "production"
```

## Settings

If you have to, you can access the settings programmatically:

```ruby
App.credentials[:env]   # => "production"
```

### Defaults

Setting | Default | Description
--------|---------|------------
`env` | `-> { ENV["RACK_ENV"] }` | environment such as `development`
`dir` | `"config/credentials"` | directory where encrypted credentials are stored
`cipher` | `"aes-256-gcm"` | any of `OpenSSL::Cipher.ciphers`
`digest` | `"sha256"` | sign digest used if the cipher doesn't support AEAD
`serializer` | `Marshal` | serializer responding to `dump` and `load`

## Development

To install the development dependencies and then run the test suite:

```
bundle install
bundle exec rake    # run tests once
bundle exec guard   # run tests whenever files are modified
```

You're welcome to [submit issues](https://github.com/svoop/dry-credentials/issues) and contribute code by [forking the project and submitting pull requests](https://docs.github.com/en/get-started/quickstart/fork-a-repo).
