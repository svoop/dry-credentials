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

  describe :[]= do
    it "writes the settings" do
      subject.credentials[:serializer] = String
      _(subject.credentials[:serializer]).must_equal String
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
        original_mtime = File.mtime("#{tmp_dir}/test.yml.enc")
        sleep 0.1
        subject.credentials do
          env 'test'
          dir tmp_dir
        end
        ENV['EDITOR'] = 'echo "added_root: ADDED ROOT" >>'
        _{ subject.credentials.edit! }.must_be_silent
        _(File.exist?("#{tmp_dir}/test.yml.enc")).must_equal true
        _(File.mtime("#{tmp_dir}/test.yml.enc")).wont_equal original_mtime
        _(subject.credentials.added_root).must_equal 'ADDED ROOT'
        _(subject.credentials.one_root).must_equal 'ONE ROOT'
      end
    end

    it "doesn't update the encrypted file if no changes were made" do
      Dir.mktmpdir do |tmp_dir|
        FileUtils.cp(fixtures_path.join('encrypted', 'test.yml.enc'), tmp_dir)
        original_mtime = File.mtime("#{tmp_dir}/test.yml.enc")
        sleep 0.1
        subject.credentials do
          env 'test'
          dir tmp_dir
        end
        ENV['EDITOR'] = 'true'
        _{ subject.credentials.edit! }.must_be_silent
        _(File.exist?("#{tmp_dir}/test.yml.enc")).must_equal true
        _(File.mtime("#{tmp_dir}/test.yml.enc")).must_equal original_mtime
      end
    end
  end

  describe :define! do
    it "defines an independent dynamic secret" do
      subject.credentials.define!(:independent_secret) { 'static after all' }
      _(subject.credentials.independent_secret).must_equal 'static after all'
    end

    it "defines a dependent dynamic secret" do
      subject.credentials.define!(:dependent_secret) do |credentials|
        credentials.three_root.three_sub.three_integer + 1
      end
      _(subject.credentials.dependent_secret).must_equal 334
    end

    it "fails when redefining an existing key" do
      _{ subject.credentials.define!(:two_root) }.must_raise Dry::Credentials::DefineError
    end

    it "is not affected by reloads" do
      subject.credentials.define!(:independent_secret) { 'static after all' }
      _(subject.credentials.independent_secret).must_equal 'static after all'
      subject.credentials.reload!
      _(subject.credentials.independent_secret).must_equal 'static after all'
    end
  end
end
