# frozen_string_literal: true

module Dry
  module Credentials
    class Extension

      def initialize
        @settings = Dry::Credentials::Settings.new
        @injected = []
      end

      # Load the credentials once
      #
      # @api private
      # @return [self]
      def load!
        helpers = Dry::Credentials::Helpers.new(self)
        if  @injected.none? && !helpers.create?
          @injected = Dry::Credentials::YAML.new(helpers.read_yaml).inject_into(self)
        end
        self
      end

      # Reload the credentials
      #
      # @return [self]
      def reload!
        singleton_class.undef_method(@injected.pop) until @injected.empty?
        self
      end

      # Edit credentials file
      #
      # @param env [String] name of the env to edit the credentials for
      # @return [self]
      def edit!(env=nil)
        helpers = Dry::Credentials::Helpers.new(self, env)
        create = helpers.create?
        yaml = helpers.read_yaml
        begin
          yaml = helpers.edit_yaml yaml
        end until helpers.yaml_valid? yaml
        helpers.write_yaml yaml
        puts [helpers.key_ev, ENV[helpers.key_ev]].join('=') if create
        reload!
      end

      # Query settings
      #
      # @param setting [String] name of the setting
      # @return [String] setting value
      def [](setting)
        @settings.send(setting)
      end

    end
  end
end
