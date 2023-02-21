require_relative '../../../spec_helper'

describe Dry::Credentials::Extension do
  subject do
    TestApp.init!
  end

  describe :[] do
    it "reads the settings" do
      _(subject.credentials[:serializer]).must_equal Marshal
    end
  end

  describe :one_root do
    it "reads the credentials" do
      _(subject.credentials.one_root).must_equal 'ONE ROOT'
    end
  end

  describe :load! do
    it "loads the credentials once" do
      before_value = subject.credentials.one_root
      _(before_value).must_equal 'ONE ROOT'
      subject.credentials.load!
      after_value = subject.credentials.one_root
      _(after_value).must_be_same_as before_value
    end
  end

  describe :reload! do
    it "reloads the credentials anew" do
      before_value = subject.credentials.one_root
      _(before_value).must_equal 'ONE ROOT'
      subject.credentials.reload!
      after_value = subject.credentials.one_root
      _(after_value).wont_be_same_as before_value
      _(after_value).must_equal before_value
    end
  end

  describe :edit! do
    it "creates a new encrypted file and prints the key" do
      Dir.mktmpdir do |tmp_dir|
        subject.credentials do
          env 'sandbox'
          dir tmp_dir
        end
        ENV['EDITOR'] = 'echo "created_root: CREATED ROOT" >'
        _{ subject.credentials.edit! }.must_output(/^SANDBOX_CREDENTIALS_KEY=\w+/)
        _(File.exist?("#{tmp_dir}/sandbox.yml.enc")).must_equal true
        _(subject.credentials.created_root).must_equal 'CREATED ROOT'
      end
    end

    it "updates the encrypted file and reloads the credentials" do
      Dir.mktmpdir do |tmp_dir|
        FileUtils.cp(fixtures_path.join('encrypted', 'test.yml.enc'), tmp_dir)
        subject.credentials do
          env 'test'
          dir tmp_dir
        end
        ENV['EDITOR'] = 'echo "added_root: ADDED ROOT" >>'
        _{ subject.credentials.edit! }.must_be_silent
        _(File.exist?("#{tmp_dir}/test.yml.enc")).must_equal true
        _(subject.credentials.added_root).must_equal 'ADDED ROOT'
        _(subject.credentials.one_root).must_equal 'ONE ROOT'
      end
    end
  end
end

describe Dry::Credentials::Extension::Helpers do
  context "no credentials file exists yet" do
    subject do
      TestApp.init!.credentials do
        env 'new'
      end.__credentials_extension__.instance_variable_get('@helpers')
    end

    describe :read_yaml do
      it "returns an empty string" do
        _(subject.read_yaml).must_equal ''
      end
    end

    describe :yaml_exist? do
      it "returns false" do
        _(subject.yaml_exist?).must_equal false
      end
    end
  end

  context "credentials file exists" do
    subject do
      TestApp.init!.__credentials_extension__.instance_variable_get('@helpers')
    end

    describe :read_yaml do
      it "returns the decoded YAML content of the file" do
        _(subject.read_yaml).must_equal fixtures_path.join('decrypted', 'test.yml').read
      end
    end

    describe :yaml_exist? do
      it "returns true" do
        _(subject.yaml_exist?).must_equal true
      end
    end

    describe :variable_name do
      it "adds postfix to env and is all upcase" do
        _(subject.variable_name).must_equal 'TEST_CREDENTIALS_KEY'
      end
    end
  end
end
