require_relative '../../../spec_helper'

describe Dry::Credentials::Extension do
  subject do
    TestApp.dup
  end

  describe :[] do
    it "reads the default settings" do
      _(subject.credentials[:serializer]).must_equal Marshal
    end
  end

  describe :load! do
  end

  describe :reload! do
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
