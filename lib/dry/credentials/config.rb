# frozen_string_literal: true

module Dry
  module Credentials
    class Config
      DEFAULTS = {
        env: -> { ENV['RACK_ENV'] },
        dir: -> { 'config/credentials' }
      }.freeze

      %i(env dir).each do |method|
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
