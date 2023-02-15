[![Version](https://img.shields.io/gem/v/dry-credentials.svg?style=flat)](https://rubygems.org/gems/dry-credentials)
[![Tests](https://img.shields.io/github/actions/workflow/status/svoop/dry-credentials/test.yml?style=flat&label=tests)](https://github.com/svoop/dry-credentials/actions?workflow=Test)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/svoop/dry-credentials.svg?style=flat)](https://codeclimate.com/github/svoop/dry-credentials/)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

# Dry::Credentials

Lightweight implementation of encrypted credentials.

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
