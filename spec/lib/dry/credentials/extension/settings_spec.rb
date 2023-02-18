require_relative '../../../../spec_helper'

class TestObject
  extend Dry::Credentials
end

describe Dry::Credentials::Extension::Settings do
  subject do
    ENV["RACK_ENV"] = "rack_environment"
    TestObject.dup
  end

  def extension
    subject.send(:__credentials_extension__)
  end


  Dry::Credentials::Extension::Settings::SETTINGS.each do |setting, default|
    describe :env do
      it "accepts block to write #{setting} and responds to #{setting} reader" do
        subject.credentials { send(setting, 'string') }
        _(extension.send(setting)).must_equal 'string'
      end

      it "converts value to String" do
        subject.credentials { send(setting, :symbol) }
        _(extension.send(setting)).must_equal 'symbol'
      end

      it "falls back to the default" do
        _(extension.send(setting)).must_equal default.call
      end
    end
  end

  it "fails for other writers" do
    _{ subject.credentials { foo "bar" } }.must_raise Dry::Credentials::UnrecognizedSettingError
  end
end
