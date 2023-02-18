# frozen_string_literal: true

module Dry
  module Credentials
    class Extension
      module Settings

        SETTINGS = {
          env: -> { ENV['RACK_ENV'] },
          dir: -> { 'config/credentials' },
          cipher: -> { 'aes-256-gcm' },
          digest: -> { 'sha256' },
          serializer: -> { 'Marshal' }
        }.freeze

        SETTINGS.each_key do |setting|
          define_method setting do |value=nil|
            if value
              instance_variable_set("@#{setting}", value.to_s)
            else
              instance_variable_get("@#{setting}") || SETTINGS[setting].call
            end
          end
        end

      end
    end
  end
end
