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
  end
end
