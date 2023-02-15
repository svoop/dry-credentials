# frozen_string_literal: true

require_relative "credentials/version"
require_relative "credentials/config"

module Dry
  module Credentials
    attr_accessor :__credentials_config

    def credentials(&block)
      __credentials_config.instance_eval &block
    end

    private

    def __credentials_config
      @__credentials_config ||= Config.new
    end
  end
end
