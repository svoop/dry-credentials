# frozen_string_literal: true

module Dry
  module Credentials
    class Extension

      def initialize
        @settings = Dry::Credentials::Settings.new
        @injected = []
        @helpers = Helpers.new(self)
      end

      # Load the credentials once
      #
      # @api private
      # @return [self]
      def load!
        @injected = @helpers.yaml.inject_into(self) if @injected.none?
        self
      end

      # Reload the credentials
      #
      # @return [self]
      def reload!
        undef_method(@injected.pop) until @injected.empty?
        self
      end

      # Edit credentials file
      #
      # @param env [String] name of the env to edit the credentials for
      # @return [self]
      def edit!(env=nil)
        puts "go edit"   # TODO:
        self
      end

      # Query settings
      #
      # @param setting [String] name of the setting
      # @return [String] setting value
      def [](setting)
        @settings.send(setting)
      end

      # Helpers class in order not to pollute the extension with methods which
      # could collide with credentials
      class Helpers
        def initialize(extension)
          @extension = extension
        end

        def yaml
          Dry::Credentials::YAML.new(encryptor.decrypt(encrypted_file.read, key: key))
        end

        private

        def key
          env = @extension[:env] or fail Dry::Credentials::EnvNotSetError
          ENV["#{env.upcase}_CREDENTIALS_KEY"]  or fail Dry::Credentials::KeyNotSetError
        end

        def encrypted_file
          env = @extension[:env] or fail Dry::Credentials::EnvNotSetError
          Pathname(@extension[:dir]).realpath.join("#{env}.yml.enc")
        end

        def encryptor
          Dry::Credentials::Encryptor.new(
            cipher: @extension[:cipher],
            digest: @extension[:digest],
            serializer: @extension[:serializer]
          )
        end
      end
    end
  end
end
