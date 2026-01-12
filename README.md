[![Version](https://img.shields.io/gem/v/dry-credentials.svg?style=flat)](https://rubygems.org/gems/dry-credentials)
[![Tests](https://img.shields.io/github/actions/workflow/status/svoop/dry-credentials/test.yml?style=flat&label=tests)](https://github.com/svoop/dry-credentials/actions?workflow=Test)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/svoop/dry-credentials.svg?style=flat)](https://codeclimate.com/github/svoop/dry-credentials/)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/svoop.svg)](https://github.com/sponsors/svoop)

# Dry::Credentials

Manage and deploy secrets (access keys, API tokens etc) in encrypted files which can safely be committed to the code repository. To decrypt and and use them, only one environment variable containing the corresponding key is required.

While similar in purpose to ActiveSupport::EncryptedConfiguration, this lightweight implementation doesn't introduce any dependencies.

* [Homepage](https://github.com/svoop/dry-credentials)
* [API](https://www.rubydoc.info/gems/dry-credentials)
* Author: [Sven Schwyn - Bitcetera](https://bitcetera.com)

Thank you for supporting free and open-source software by sponsoring on [GitHub](https://github.com/sponsors/svoop) or on [Donorbox](https://donorbox.com/bitcetera). Any gesture is appreciated, from a single Euro for a ☕️ cup of coffee to 🍹 early retirement.

## Install

Add the following to the <tt>Gemfile</tt> or <tt>gems.rb</tt> of your [Bundler](https://bundler.io) powered Ruby project:

```ruby
gem 'dry-credentials'
```

And then install the bundle:

```
bundle install
```

See [Integrations](#integrations) below for how to integrate Dry::Credentials into frameworks.

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

⚠️ The `dir` must exist and have the proper permissions set.

Now initialize the credentials for this `env`:

```ruby
App.credentials.edit!
```

It creates `/path/to/credentials/sandbox.yml.enc` (where the encrypted credentials are stored) and opens this file using your favourite editor as per the `EDITOR` environment variable.

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
SANDBOX_CREDENTIALS_KEY=68656973716a4e706e336733377245732b6e77584c6c772b5432446532456f674767664271374a623876383d
```

⚠️ In case you've entered invalid YAML, a warning will be printed and the editor reopens immediately.

To decrypt the credentials and use them in your app, you have to set just this one environment variable containing the key, in this case:

```sh
export SANDBOX_CREDENTIALS_KEY=68656973716a4e706e336733377245732b6e77584c6c772b5432446532456f674767664271374a623876383d
```

Alternatively, you can omit the first part of the variable name. Such a key will be used for any app environment, but a more specific key will always take precedence. This is particularly useful when working with containerized setups:

```sh
export CREDENTIALS_KEY=68656973716a4e706e336733377245732b6e77584c6c772b5432446532456f674767664271374a623876383d
```

You can also read keys from files which is the recommended way when using [secrets in Docker Compose](https://docs.docker.com/compose/how-tos/use-secrets/). Just append `_FILE` to the corresponding environment variable name and set it to the path from which the secret can be read, for example:

```db
export SANDBOX_CREDENTIALS_KEY_FILE=/run/secrets/sandbox_credentials_key
export CREDENTIALS_KEY_FILE=/run/secrets/credentials_key
```

With this in place, you can use the decrypted credentials anywhere in your app:

```ruby
App.credentials.otp.secret_key
# => "ZcikLNiUQoqOo594oH2eqw04HPclhjkpgvpBik/40oU="

App.credentials.otp.meta.realm
# => "main"
```

## Environments

Credentials are isolated into environments which most likely will, but don't necessarily have to align with the environments of the app framework you're using.

By default, the current environment is read from `APP_ENV`. You shouldn't use `RACK_ENV` for this, [here's why](https://github.com/rack/rack/issues/1546).

⚠️ For safety reasons, don't share the same key across multiple environments!

## Reload credentials

The credentials are lazy loaded when queried for the first time. After that, changes in the encrypted credentials files are not taken into account at runtime for efficiency reasons.

However, you can schedule a reload:

```ruby
App.credentials.reload!
```

The reload is not done immediately but the next time credentials are queried.

## Edit credentials

This gem does not provide any CLI tools to edit the credentials. You should integrate it into your app instead e.g. with a Rake task or an extension to the CLI tool of the app framework you're using.

You can explicitly pass the environment to edit:

```ruby
App.credentials.edit! "production"
```

Editing credentials implicitly schedules a `reload!`.

## Dynamic secrets

In case you have to partition secrets beyond environments, you can set dynamic secrets which are composed on the fly. Here's an example.

You want to be able to connect to a shared database for the test environment, but the database URL differs whether you run the tests locally or on your favourite CI platform. To differ between the two, you set an environment variable `CONTEXT` which is either `local` or `ci` and you defined the secrets accordingly:

```yaml
database_url:
  local: postgres://localhost:5432/example
  ci: postgres://testuser:testpassword@remote.db.example.com:5432/example
```

To get the actual database URL, you have to:

```ruby
App.credentials.database_url.send(ENV['CONTEXT'])
```

This is okay, but it may grow a lot longer and less readable in a real app. Enter dynamic secrets which are composed according to your needs:

```ruby
App.credentials.define! :current_database_url do |credentials|
  credentials.database_url.send(ENV['CONTEXT'])
end
```

Dynamic secrets are then available like any other secret, however, the block is called every time you query the dynamic secret:

```ruby
App.credentials.current_database_url   # => "postgres://localhost..."
```

⚠️ Don't try to use the same key for a dynamic secret as for an existing regular one since this could create an endless loop and therefore any such attempt will raise a `Dry::Credentials::DefineError`.

## Settings

If you have to, you can access the settings programmatically:

```ruby
App.credentials[:env]   # => "production"
```

### Defaults

Setting | Default | Description
--------|---------|------------
`env` | `-> { ENV["APP_ENV"] }` | environment such as `development`
`dir` | `"config/credentials"` | directory where encrypted credentials are stored
`cipher` | `"aes-256-gcm"` | any of `OpenSSL::Cipher.ciphers`
`digest` | `"sha256"` | sign digest used if the cipher doesn't support AEAD
`serializer` | `Marshal` | serializer responding to `dump` and `load`

## Integrations

### Bridgetown

The [bridgetown_credentials gem](https://github.com/svoop/bridgetown_credentials) integrates Dry::Credentials into your [Bridgetown](https://www.bridgetownrb.com) site.

### Hanami 2

To use credentials in a [Hanami 2](https//hanami.org) app, first add this gem to the Gemfile of the app and then create a provider `config/providers/credentials.rb`:

```ruby
# frozen_string_literal: true

Hanami.app.register_provider :credentials do
  prepare do
    require "dry-credentials"
  end

  start do
    Dry::Credentials::Extension.new.then do |credentials|
      credentials[:env] = Hanami.env
      credentials[:dir] = Hanami.app.root.join(credentials[:dir])
      credentials[:dir].mkpath
      credentials.load!
      register "credentials", credentials
    end
  end
end
```

Next up are Rake tasks `lib/tasks/credentials.rake`:

```ruby
namespace :credentials do
  desc "Edit (or create) the encrypted credentials file"
  task :edit, [:env] => [:environment] do |_, args|
    Hanami.app.prepare(:credentials)
    Hanami.app['credentials'].edit! args[:env]
  end
end
```

(As of Hanami 2.1, you have to [explicitly load such tasks in the Rakefile](https://github.com/hanami/hanami/issues/1375) yourself.)

You can now create a new credentials file for the development environment:

```
rake credentials:edit
```

This prints the credentials key you have to set in `.env`:

```
DEVELOPMENT_CREDENTIALS_KEY=...
```

The credentials are now available anywhere you inject them:

```ruby
module MyHanamiApp
  class ApiKeyPrinter
    include Deps[
      "credentials"
    ]

    def call
      puts credentials.api_key
    end
  end
end
```

You can use the credentials in other providers. Say, you want to pass the [ROM](https://rom-rb.org/) database URL (which contains the connection password) using credentials instead of settings. Simply replace `target["settings"].database_url` with `target["credentials"].database_url` and you're good to go:

```ruby
Hanami.app.register_provider :persistence, namespace: true do
  prepare do
    require "rom"

    config = ROM::Configuration.new(:sql, target["credentials"].database_url)

    register "config", config
    register "db", config.gateways[:default].connection
  end

  (...)
end
```

Finally, if you have trouble using the credentials in slices, you might have to [share this app component](https://www.rubydoc.info/gems/hanami/Hanami/Config#shared_app_component_keys-instance_method) in `config/app.rb`:

```ruby
module MyHanamiApp
  class App < Hanami::App
    config.shared_app_component_keys += ["credentials"]
  end
end
```

### Ruby on Rails

ActiveSupport implements [encrypted configuration](https://www.rubydoc.info/gems/activesupport/ActiveSupport/EncryptedConfiguration) which is used by `rails credentials:edit` [out of the box]((https://guides.rubyonrails.org/security.html#custom-credentials)). There not much benefit from introducing Dry::Credentials as an additional dependency.

### Rodbot

Dry::Credentials is integrated into [Rodbot](https://github.com/svoop/rodbot) out of the box, see [the README for more](https://github.com/svoop/rodbot/blob/main/README.md#credentials).

## Development

To install the development dependencies and then run the test suite:

```
bundle install
bundle exec rake    # run tests once
bundle exec guard   # run tests whenever files are modified
```

You're welcome to join the [discussion forum](https://github.com/svoop/dry-credentials/discussions) to ask questions or drop feature ideas, [submit issues](https://github.com/svoop/dry-credentials/issues) you may encounter or contribute code by [forking this project and submitting pull requests](https://docs.github.com/en/get-started/quickstart/fork-a-repo).
