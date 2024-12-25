## Main

Nothing so far

## 0.3.1

#### Changes
* Update Ruby to 3.4

## 0.3.0

#### Additions
* Support generic fallback environment variable +CREDENTIALS_KEY+

## 0.2.1

#### Additions
* Add square brackets setter for settings
* Explain integrations for Bridgetown, Hanami 2 and Rodbot

## 0.2.0

#### Breaking changes
* Fall back to `APP_ENV` instead of `RACK_ENV`

#### Fixes
* Don't re-encrypt if credentials haven't been modified

## 0.1.0

#### Initial implementation
* Require Ruby 3.0 or newer
* Class mixin featuring the `credentials` macro:
  * Block to change (default) settings such as the cipher
  * Bang method to edit or reload credentials
  * Arbitrary method chain to query credentials
