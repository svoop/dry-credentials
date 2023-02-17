# frozen_string_literal: true

require "yaml"
require "securerandom"
require "openssl"
require "base64"

require_relative "credentials/version"
require_relative "credentials/errors"
require_relative "credentials/config"
require_relative "credentials/encryptor"

module Dry
  module Credentials
    attr_accessor :__credentials_config

    def credentials(&block)
      __credentials_config.instance_eval &block
    rescue NoMethodError
      raise UnrecognizedConfigError
    end

    private

    def __credentials_config
      @__credentials_config ||= Config.new
    end
  end
end
