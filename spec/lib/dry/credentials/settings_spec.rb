require_relative '../../../spec_helper'

describe Dry::Credentials::Settings do
  subject do
    TestApp.init
  end

  it "accepts block to write setting and responds to setting reader" do
    subject.credentials { digest 'my123' }
    _(subject.credentials[:digest]).must_equal 'my123'
  end

  it "resolves Proc values by calling them" do
    subject.credentials { digest -> { 'my234' } }
    _(subject.credentials[:digest]).must_equal 'my234'
  end

  it "falls back to the default value" do
    _(subject.credentials[:serializer]).must_equal Marshal
  end

  it "fails for unrecognized writers" do
    _{ subject.credentials { foo "bar" } }.must_raise Dry::Credentials::UnrecognizedSettingError
  end
end
