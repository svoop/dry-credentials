require_relative '../../../spec_helper'

SEPARATOR = Dry::Credentials::Encryptor::SEPARATOR
BASE64_RE = %r([a-zA-Z0-9+/]).freeze
HEX_RE = %r([a-f0-9]).freeze

CIPHERS = {
  'aes-256-gcm' => [32, %r(\A#{BASE64_RE}+=*#{SEPARATOR}#{BASE64_RE}{16}#{SEPARATOR}#{BASE64_RE}{22}==\z)],   # AEAD supported
  'aria-128-ctr' => [16, %r(\A#{BASE64_RE}+=*#{SEPARATOR}#{BASE64_RE}{22}==#{SEPARATOR}#{HEX_RE}{64}\z)]      # AEAD not supported
}.freeze

describe Dry::Credentials::Encryptor do
  let :payload do
    SecureRandom.alphanumeric(10)
  end

  CIPHERS.each do |cipher, (key_length, encrypted_re)|
    context cipher do
      subject do
        Dry::Credentials::Encryptor.new(cipher: cipher)
      end

      describe :generate_key do
        it "generates random keys with the correct length of #{key_length} bytes" do
          keys = 100.times.map do
            subject.generate_key.tap do |key|
              _(Base64.decode64([key].pack('H*')).length).must_equal key_length
            end
          end
          _(keys.uniq.count).must_equal 100
        end
      end

      describe :encrypt do
        it "encrypts the string" do
          _(subject.encrypt(payload, key: subject.generate_key)).must_match(encrypted_re)
        end
      end

      describe :decrypt do
        let :key do
          subject.generate_key
        end

        let :encoded do
          subject.encrypt(payload, key: key)
        end

        it "performs a successful roundtrip" do
          _(subject.decrypt(encoded, key: key)).must_equal payload
        end

        it "fails if the payload, iv or auth_tag is altered" do
          groups = encoded.split(SEPARATOR)
          3.times do |group|
            groups[group][0] = (groups[group][0] == '0' ? '1' : '0')
            _{ subject.decrypt(groups.join(SEPARATOR), key: key) }.must_raise Dry::Credentials::InvalidEncryptedObjectError
          end
        end
      end
    end
  end
end
