gem 'minitest'

require 'debug'
require 'pathname'

require 'minitest/autorun'
require Pathname(__dir__).join('..', 'lib', 'dry-credentials')

require 'minitest/substitute'
require 'minitest/flash'

Minitest.load_plugins

class Minitest::Spec
  class << self
    alias_method :context, :describe
  end
end

def fixtures_path
  Pathname(__dir__).join('fixtures')
end

ENV['TEST_CREDENTIALS_KEY'] = '6e625675397271756145726c7069775a65693046386953386a4574765061467a52574e7854687353486e593d'

class TestApp
  extend Dry::Credentials

  def self.init
    instance_variable_set(:'@__credentials_extension__', nil)
    credentials do
      env 'test'
      dir fixtures_path.join('encrypted').to_s
    end
    self
  end
end

class Dir
  module Tmpname
    class << self
      alias_method :original_create, :create

      def create(...)
        $latest_tmpname = original_create(...)
      end
    end
  end
end
