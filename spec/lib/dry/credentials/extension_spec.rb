require_relative '../../../spec_helper'

class TestObject
  extend Dry::Credentials
end

describe Dry::Credentials::Extension do
  subject do
    TestObject.dup
  end

  describe :[] do
    it "reads the settings" do
      _(subject.credentials[:dir]).must_equal 'config/credentials'
    end
  end

  describe :edit! do
    context "initialize new credentials" do
    end

    context "edit existing credentials" do
    end
  end

  describe :method_missing do
    it "returns the decrypted credentials" do
    end

    it "fails if queried credentials are not set" do
    end
  end
end
