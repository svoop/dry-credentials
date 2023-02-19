# frozen_string_literal: true

module Dry
  module Credentials
    class Settings

      DEFAULT_SETTINGS = {
        env: -> { ENV['RACK_ENV'] },
        dir: 'config/credentials',
        cipher: 'aes-256-gcm',
        digest: 'sha256',
        serializer: Marshal
      }.freeze

      def initialize
        @settings = {}
      end

      def method_missing(key, value=nil)
        fail Dry::Credentials::UnrecognizedSettingError, key unless DEFAULT_SETTINGS.has_key? key
        if value
          @settings[key] = value
        else
          resolve(@settings[key] || DEFAULT_SETTINGS[key])
        end
      end

      private

      def resolve(value)
        if value.respond_to? :call
          value.call
        else
          value
        end
      end

    end
  end
end
