# frozen_string_literal: true

module Dry
  module Credentials
    class YAML

      # @param string [String] YAML document content
      def initialize(yaml)
        @yaml = yaml
        @hash = ::YAML.safe_load yaml
        fail Dry::Credentials::YAMLFormatError unless @hash.instance_of? Hash
      rescue Psych::DisallowedClass
        raise Dry::Credentials::YAMLFormatError
      end

      # Define readers for the first level of the credentials on the
      # given +object+.
      #
      # @param [Object] object to inject the methods into
      # @return [Array] injected methods
      def inject_into(object)
        Query.new(@hash).send(:inject_into, object)
      end

      class Query
        # @param hash [Hash] hash of hashes containing the credentials
        def initialize(hash)
          @hash = hash
          inject_into self
        end

        # Get all credentials below the current node as a hash.
        #
        # @return [Hash] credentials
        def to_h
          @hash
        end

        private

        def inject_into(object)
          @hash.each do |key, value|
            object.define_singleton_method key do
              if value.instance_of? Hash
                Query.new value
              else
                value
              end
            end
          end
          @hash.keys
        end
      end

    end
  end
end
