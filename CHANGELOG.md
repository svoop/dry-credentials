## Main

#### Breaking Changes

* Fall back to `APP_ENV` instead of `RACK_ENV`

## 0.1.0

#### Initial Implementation

* Require Ruby 3.0 or newer
* Class mixin featuring the `credentials` macro:
  * Block to change (default) settings such as the cipher
  * Bang method to edit or reload credentials
  * Arbitrary method chain to query credentials
