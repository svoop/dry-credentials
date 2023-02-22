require_relative '../../../spec_helper'

describe Dry::Credentials::Helpers do
  context "no credentials file exists yet" do
    subject do
      Dry::Credentials::Helpers.new(
        TestApp.init.credentials { env 'new' }.__credentials_extension__
      )
    end

    describe :read_yaml do
      it "returns an empty string" do
        _(subject.read_yaml).must_equal ''
      end
    end

    describe :edit_yaml do
      it "removes the tempfile on regular exit" do
        ENV['EDITOR'] = 'echo "oggy: best dog friend ever" >'
        _(subject.edit_yaml('')).must_equal "oggy: best dog friend ever\n"
        _(File.exist? $latest_tmpname).must_equal false
      end
    end

    describe :create? do
      it "returns true" do
        _(subject.create?).must_equal true
      end
    end
  end

  context "credentials file exists" do
    subject do
      Dry::Credentials::Helpers.new(
        TestApp.init.__credentials_extension__
      )
    end

    describe :read_yaml do
      it "returns the decoded YAML content of the file" do
        _(subject.read_yaml).must_equal fixtures_path.join('decrypted', 'test.yml').read
      end
    end

    describe :create? do
      it "returns false" do
        _(subject.create?).must_equal false
      end
    end

    describe :key_ev do
      it "adds postfix to env and is all upcase" do
        _(subject.key_ev).must_equal 'TEST_CREDENTIALS_KEY'
      end
    end
  end
end
