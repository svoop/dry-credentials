require_relative '../../spec_helper'

class TestObject
  extend Dry::Credentials
end

describe Dry::Credentials do
  subject do
    TestObject.dup
  end

  def config
    subject.send(:__credentials_config)
  end

  describe :credentials do
    describe :env do
      it "accepts block to write env and responds to env reader" do
        subject.credentials { env "environment" }
        _(config.env).must_equal "environment"
      end

      it "converts value to String" do
        subject.credentials { env :environment }
        _(config.env).must_equal "environment"
      end

      it "defaults to RACK_ENV" do
        ENV["RACK_ENV"] = "rack_environment"
        _(config.env).must_equal "rack_environment"
      end
    end

    describe :dir do
      it "accepts block to write dir and responds to dir reader" do
        subject.credentials { dir "string/dir" }
        _(config.dir).must_equal "string/dir"
      end

      it "converts value to String" do
        subject.credentials { dir Pathname('pathname/dir')  }
        _(config.dir).must_equal "pathname/dir"
      end

      it "defaults to config/credentials" do
        _(config.dir).must_equal "config/credentials"
      end
    end

    describe :cipher do
      it "accepts block to write cipher and responds to cipher reader" do
        subject.credentials { cipher "my-cipher" }
        _(config.cipher).must_equal "my-cipher"
      end

      it "converts value to String" do
        subject.credentials { cipher :'your-cipher'  }
        _(config.cipher).must_equal "your-cipher"
      end

      it "defaults to aes-256-gcm" do
        _(config.cipher).must_equal 'aes-256-gcm'
      end
    end

    it "fails for other writers" do
      _{ subject.credentials { foo "bar" } }.must_raise Dry::Credentials::UnrecognizedConfigError
    end
  end

  describe :edit! do
    context "initialize new credentials" do
    end

    context "edit existing credentials" do
    end
  end
end
