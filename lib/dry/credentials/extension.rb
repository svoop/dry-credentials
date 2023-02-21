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
        if  @injected.none? && @helpers.yaml_exist?
          @injected = Dry::Credentials::YAML.new(@helpers.read_yaml).inject_into(self)
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
        create = !@helpers.yaml_exist?
        tempfile = Tempfile.new('dryc')
        tempfile.write @helpers.read_yaml
        tempfile.close
        system %Q(#{ENV['EDITOR']} "#{tempfile.path}")
        @helpers.write_yaml File.read(tempfile.path)
        puts [@helpers.variable_name, ENV[@helpers.variable_name]].join('=') if create
        reload!
      ensure
        tempfile.unlink
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

        def read_yaml
          return '' unless yaml_exist?
          encryptor.decrypt(encrypted_file.read, key: key)
        end

        def write_yaml(yaml)
          encrypted_file.write(encryptor.encrypt(yaml, key: key))
        end

        def yaml_exist?
          encrypted_file.exist?
        end

        def variable_name
          env = @extension[:env] or fail Dry::Credentials::EnvNotSetError
          "#{env.upcase}_CREDENTIALS_KEY"
        end

        private

        def key
          if yaml_exist?
            ENV[variable_name]  or fail Dry::Credentials::KeyNotSetError
          else
            ENV[variable_name] = encryptor.generate_key
          end
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
