# frozen_string_literal: true

module Dry
  module Credentials
    class YAML

      # @param string [String] YAML document content
      def initialize(string)
        @hash = ::YAML.safe_load string
        fail Dry::Credentials::YAMLFormatError unless @hash.instance_of? Hash
      rescue Psych::DisallowedClass
        raise Dry::Credentials::YAMLFormatError
      end

      # Get a query object to fetch the credentials using method chains.
      #
      # @return [Dry::Credentials::YAML::Query] query object
      def query
        Query.new(@hash)
      end

      class Query
        # @param hash [Hash] hash of hashes containing the credentials
        def initialize(hash)
          @hash = hash
          __populate__
        end

        # Get all credentials below the current node as a hash.
        #
        # @return [Hash] credentials
        def to_h
          @hash
        end

        def method_missing(*)
          fail Dry::Credentials::UndefinedError
        end

        private

        def __populate__
          @hash.each do |key, value|
            define_singleton_method key do
              if value.instance_of? Hash
                self.class.new value
              else
                value
              end
            end
          end
        end
      end

    end
  end
end
