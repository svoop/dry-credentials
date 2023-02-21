require_relative '../../../spec_helper'

describe Dry::Credentials::YAML do
  describe :new do
    subject do
      Dry::Credentials::YAML
    end

    it "fails on invalid YAML files" do
      _{ subject.new(fixtures_path.join('decrypted', 'invalid.yml').read) }.must_raise Dry::Credentials::YAMLFormatError
    end

    it "fails on unsafe YAML files" do
      _{ subject.new(fixtures_path.join('decrypted', 'unsafe.yml').read) }.must_raise Dry::Credentials::YAMLFormatError
    end
  end

  describe :inject_into do
    subject do
      Object.new.tap do |object|
        Dry::Credentials::YAML.new(fixtures_path.join('decrypted', 'test.yml').read).inject_into(object)
      end
    end

    it "returns credentials on value nodes" do
      _(subject.one_root).must_equal 'ONE ROOT'
      _(subject.two_root.two_string).must_equal 'TWO STRING'
      _(subject.three_root.three_string).must_equal 'THREE STRING'
      _(subject.three_root.three_array).must_equal ['THREE ARRAY ONE', 'THREE ARRAY TWO']
      _(subject.three_root.three_sub.three_integer).must_equal 333
    end

    it "returns query object on tree nodes" do
      _(subject.three_root).must_be_instance_of Dry::Credentials::YAML::Query
    end

    it "fails on undefined nodes" do
      _{ subject.undefined }.must_raise NoMethodError
    end

    describe Dry::Credentials::YAML::Query do
      describe :to_h do
        it "returns the credentials below a tree node in a Hash" do
          _(subject.three_root.three_sub.to_h).must_equal({ "three_integer" => 333 })
        end
      end
    end
  end

end
