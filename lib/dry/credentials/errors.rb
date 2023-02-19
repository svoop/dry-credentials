# frozen_string_literal: true

module Dry
  module Credentials
    Error = Class.new(::StandardError)

    UnrecognizedSettingError = Class.new(Error)
    EnvNotSetError = Class.new(Error)
    KeyNotSetError = Class.new(Error)
    InvalidEncryptedObjectError = Class.new(Error)
    YAMLFormatError = Class.new(Error)
  end
end
