require_relative '../../spec_helper'

describe Dry::Credentials do
  subject do
    TestApp.init
  end

  describe :credentials do
    context "with block" do
      it "returns self to allow chaining" do
        _(subject.credentials {}).must_equal subject
      end
    end

    context "without block" do
      it "returns the extension object" do
        _(subject.credentials).must_be_instance_of Dry::Credentials::Extension
      end
    end
  end
end
