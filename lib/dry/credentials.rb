# frozen_string_literal: true

require "tempfile"
require "yaml"
require "securerandom"
require "openssl"
require "base64"

require_relative "credentials/version"
require_relative "credentials/errors"
require_relative "credentials/encryptor"
require_relative "credentials/yaml"
require_relative "credentials/settings"
require_relative "credentials/extension"

module Dry
  module Credentials
    def credentials(&block)
      if block
        __credentials_extension__
          .instance_variable_get('@settings')
          .instance_eval(&block)
      else
        __credentials_extension__.load!
      end
    end

    def __credentials_extension__
      @__credentials_extension__ ||= Extension.new
    end
  end
end
