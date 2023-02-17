# frozen_string_literal: true

module Dry
  module Credentials
    Error = Class.new(::StandardError)

    UnrecognizedConfigError = Class.new(Error)
    InvalidEncryptedObject = Class.new(Error)
  end
end
