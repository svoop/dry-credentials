# frozen_string_literal: true

module Dry
  module Credentials
    class Config
      DEFAULTS = {
        env: -> { ENV['RACK_ENV'] },
        dir: -> { 'config/credentials' },
        cipher: -> { 'aes-256-gcm' },
        digest: -> { 'sha256' },
        serializer: -> { Marshal }
      }.freeze

      DEFAULTS.each_key do |method|
        define_method method do |value=nil|
          if value
            instance_variable_set("@#{method}", value.to_s)
          else
            instance_variable_get("@#{method}") || DEFAULTS[method].call
          end
        end
      end
    end
  end
end
