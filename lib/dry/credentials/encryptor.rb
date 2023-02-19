# frozen_string_literal: true

# Inspired by +ActiveSupport::EncryptedConfiguration+, the most recent compare
# to pinpoint newly discovered safety issues was done against version 7.0.4.2.

module Dry
  module Credentials
    class Encryptor

      DEFAULT_CIPHER = 'aes-256-gcm'
      DEFAULT_DIGEST = 'sha256'
      DEFAULT_SERIALIZER = Marshal
      SEPARATOR = '--'

      attr_reader :cipher

      # @param cipher [String] any of +OpenSSL::Cipher.ciphers+
      # @param digest [String] any of +openssl list+
      # @param serializer [Class] must respond to +dump+ and +load+
      def initialize(cipher: DEFAULT_CIPHER, digest: DEFAULT_DIGEST, serializer: DEFAULT_SERIALIZER)
        @cipher = OpenSSL::Cipher.new(cipher)
        @digest, @serializer = digest, serializer
      end

      # Generate a random key with the length requird by the current cipher,
      # then Base64 encodes and unpacks all bytes to hex.
      #
      # @return [String] key
      def generate_key
        unpack(encode(SecureRandom.bytes(cipher.key_len)))
      end

      # Encrypts the object
      #
      # Relies on encrypted authenticated encryption mode if available for the
      # selected cipher. Otherwise, the encrypted string is HMAC signed.
      #
      # @param object [Object] object to be encrypted
      # @param key [String] key (Base64 encoded and unpacked to hex)
      # @return [String] encrypted and authenticated/signed string
      def encrypt(object, key:)
        cipher.encrypt
        cipher.key = decoded_key = decode(pack(key.strip))
        iv = cipher.random_iv
        cipher.auth_data = '' if aead?
        cipher.update(@serializer.dump(object)).then do |data|
          data << cipher.final
          data = encode(data) + SEPARATOR + encode(iv)
          data << SEPARATOR + if aead?
            encode(cipher.auth_tag)
          else
            hmac(decoded_key, data)
          end
        end
      end

      # Decrypts the encrypted object
      #
      # @param encrypted_object [String] encrypted object to be decrypted
      # @param key [String] key (Base64 encoded and unpacked to hex)
      # @return [Object] verified and decrypted object
      def decrypt(encrypted_object, key:)
        cipher.decrypt
        cipher.key = decoded_key = decode(pack(key.strip))
        payload, iv, auth_tag = encrypted_object.strip.split(SEPARATOR)
        if auth_tag.nil? ||
          (aead? && decode(auth_tag).bytes.length != auth_tag_length) ||
          (!aead? && hmac(decoded_key, payload + SEPARATOR + iv) != auth_tag)
        then
          fail Dry::Credentials::InvalidEncryptedObjectError
        end
        cipher.iv = decode(iv)
        if aead?
          cipher.auth_tag = decode(auth_tag)
          cipher.auth_data = ''
        end
        cipher.update(decode(payload)).then do |data|
          data << cipher.final
          @serializer.load(data)
        end
      rescue OpenSSL::Cipher::CipherError, TypeError, ArgumentError
        raise Dry::Credentials::InvalidEncryptedObjectError
      end

      private

      # @example
      #   encode("abc")   # => "YWJj"
      def encode(string)
        Base64.strict_encode64(string)
      end

      # @example
      #   decode("YWJj")   # => "abc"
      def decode(string)
        Base64.strict_decode64(string)
      end

      # @example
      #   unpack("YWJj")   # => "59574a6a"
      def unpack(string)
        string.unpack1('H*')
      end

      # @example
      #   pack("59574a6a")   # => "YWJj"
      def pack(string)
        [string].pack('H*')
      end

      # Whether the cipher supports AEAD (Authenticated Encryption with
      # Associated Data) or not - in which case a HMAC signature using the
      # +digest+ is used instead
      def aead?
        @auth ||= cipher.authenticated?
      end

      def hmac(key, string)
        OpenSSL::HMAC.hexdigest(@digest, key, string)
      end

      # @see https://github.com/ruby/openssl/issues/63
      def auth_tag_length
        16
      end

    end
  end
end
