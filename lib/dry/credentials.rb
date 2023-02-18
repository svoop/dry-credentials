# frozen_string_literal: true

require "yaml"
require "securerandom"
require "openssl"
require "base64"

require_relative "credentials/version"
require_relative "credentials/errors"
require_relative "credentials/encryptor"

require_relative "credentials/extension/settings"
require_relative "credentials/extension"

module Dry
  module Credentials
    attr_accessor :__credentials_extension__

    def credentials(&block)
      return __credentials_extension__ unless block
      begin
        __credentials_extension__.instance_eval &block
      rescue NoMethodError
        raise UnrecognizedSettingError
      end
    end

    private

    def __credentials_extension__
      @__credentials_extension__ ||= Extension.new
    end
  end
end
