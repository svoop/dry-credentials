require_relative '../../../spec_helper'

class TestObject
  extend Dry::Credentials
end

describe Dry::Credentials::Settings do
  subject do
    ENV["RACK_ENV"] = "rack_environment"
    TestObject.dup
  end

  Dry::Credentials::Settings::DEFAULT_SETTINGS.each_key do |setting|
    describe setting do
      it "accepts block to write #{setting} and responds to #{setting} reader" do
        subject.credentials { send(setting, 'string') }
        _(subject.credentials[setting]).must_equal 'string'
      end
    end
  end

  it "resolves Proc values by calling them" do
    subject.credentials { env -> { 'sandbox' } }
    _(subject.credentials[:env]).must_equal 'sandbox'
  end

  it "falls back to the default value" do
    subject.credentials { dir nil }
    _(subject.credentials[:dir]).must_equal 'config/credentials'
  end

  it "fails for unrecognized writers" do
    _{ subject.credentials { foo "bar" } }.must_raise Dry::Credentials::UnrecognizedSettingError
  end
end
