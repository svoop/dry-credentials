# frozen_string_literal: true

module Dry
  module Credentials
    class Extension

      def initialize
        @settings = Dry::Credentials::Settings.new
      end

      # Query settings
      #
      # @param setting [String] name of the setting
      # @return [String] setting value
      def [](setting)
        @settings.send(setting)
      end

      # Edit credentials file
      #
      # @param env [String] name of the env to edit the credentials for
      def edit!(env=nil)
        puts "go edit"   # TODO:
      end

      # Query credentials
      def method_missing(key)
        # TODO: load YAML file to @yaml
        @yaml.query.send(key)
      end

    end
  end
end
