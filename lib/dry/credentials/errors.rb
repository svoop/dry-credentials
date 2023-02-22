# frozen_string_literal: true

module Dry
  module Credentials
    class UnrecognizedSettingError < StandardError
      def initialize(msg='setting not recognized') = super
    end

    class EnvNotSetError < StandardError
      def initialize(msg='env must be set') = super
    end

    class KeyNotSetError < StandardError
      def initialize(msg='key must be set') = super
    end

    class InvalidEncryptedObjectError < StandardError
      def initialize(msg='corrupt encrypted object or wrong key') = super
    end

    class YAMLFormatError < StandardError
      def initialize(msg='top level must be a dictionary') = super
    end
  end
end
