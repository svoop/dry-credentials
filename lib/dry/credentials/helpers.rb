# frozen_string_literal: true

module Dry
  module Credentials
    class Helpers

      # Helpers wrapped in a separate class in order not to pollute the
      # extension with methods that could collide with credentials
      #
      # @param extension [Dry::Credentials::Extension] extension using the helpers
      # @param env [String, nil] overrides env setting
      def initialize(extension, env=nil)
        @extension = extension
        @env = env || extension[:env]
      end

      # Read the encrypted file and return the decrypted YAML content
      #
      # @return [String] YAML content
      def read_yaml
        return '' if create?
        encryptor.decrypt(encrypted_file.read, key: key)
      end

      # Write the decrypted YAML content to the encrypted file
      #
      # @param yaml [String] YAML content
      def write_yaml(yaml)
        encrypted_file.write(encryptor.encrypt(yaml, key: key))
      end

      # Open the given YAML in the preferred editor
      #
      # @param yaml [String] YAML content to edit
      # @return [String] edited YAML content
      def edit_yaml(yaml)
        Tempfile.create('dryc') do |tempfile|
          tempfile.write yaml
          tempfile.close
          system %Q(#{ENV['EDITOR']} "#{tempfile.path}")
          File.read(tempfile.path)
        end
      end

      # Whether the YAML content can be read
      #
      # @param yaml [String] YAML content
      # @return [Boolean]
      def yaml_valid?(yaml)
        Dry::Credentials::YAML.new(yaml)
        true
      rescue Dry::Credentials::YAMLFormatError, Psych::SyntaxError => error
        warn "WARNING: #{error.message}"
        false
      end

      # Whether a new encrypted file will be created
      #
      # @return [Boolean]
      def create?
        !encrypted_file.exist?
      end

      # Name of the environment variable holding the key
      #
      # @return [String]
      def key_ev
        fail Dry::Credentials::EnvNotSetError unless @env
        "#{@env.upcase}_CREDENTIALS_KEY"
      end

      private

      def key
        if create?
          ENV[key_ev] = encryptor.generate_key
        else
          (ENV[key_ev] || ENV['CREDENTIALS_KEY']) or fail Dry::Credentials::KeyNotSetError
        end
      end

      def encrypted_file
        fail Dry::Credentials::EnvNotSetError unless @env
        Pathname(@extension[:dir]).realpath.join("#{@env}.yml.enc")
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
