require_relative '../../../spec_helper'

describe Dry::Credentials::Extension do
  subject do
    TestApp.init
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

    it "uses the given env instead of the env setting" do
      Dir.mktmpdir do |tmp_dir|
        subject.credentials do
          env 'foobar'
          dir tmp_dir
        end
        ENV['EDITOR'] = 'echo "created_root: CREATED ROOT" >'
        _{ subject.credentials.edit! 'sandbox' }.must_output(/^SANDBOX_CREDENTIALS_KEY=\w+/)
        _(File.exist?("#{tmp_dir}/sandbox.yml.enc")).must_equal true
        subject.credentials do
          env 'sandbox'
        end
        _(subject.credentials.created_root).must_equal 'CREATED ROOT'
      end
    end

    it "loops in case of invalid YAML content" do
      Dir.mktmpdir do |tmp_dir|
        subject.credentials do
          env 'sandbox'
          dir tmp_dir
        end
        File.write("#{tmp_dir}/tries.txt", "first_invalid\nsecond_valid: SECOND VALID\n")
        ENV['EDITOR'] = "sed -i~ -e '1 w /dev/stdout' -e '1d' #{tmp_dir}/tries.txt >"
        _{ subject.credentials.edit! }.must_output(/^SANDBOX_CREDENTIALS_KEY=\w+/, /WARNING/)
        _(File.exist?("#{tmp_dir}/sandbox.yml.enc")).must_equal true
        _(subject.credentials.second_valid).must_equal 'SECOND VALID'
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
