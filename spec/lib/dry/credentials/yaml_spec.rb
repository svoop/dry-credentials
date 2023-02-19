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
      _(subject.main_one.string_one).must_equal 'STRING ONE'
      _(subject.main_one.array_one).must_equal ['ELEMENT ONE', 'ELEMENT TWO']
      _(subject.main_one.sub_one.string_two).must_equal 'STRING TWO'
      _(subject.main_two.string_three).must_equal 'STRING THREE'
    end

    it "returns query object on tree nodes" do
      _(subject.main_one).must_be_instance_of Dry::Credentials::YAML::Query
    end

    it "fails on undefined nodes" do
      _{ subject.undefined }.must_raise NoMethodError
    end

    describe Dry::Credentials::YAML::Query do
      describe :to_h do
        it "returns the credentials below a tree node in a Hash" do
          _(subject.main_one.sub_one.to_h).must_equal({ "string_two" => "STRING TWO" })
        end
      end
    end
  end
end
