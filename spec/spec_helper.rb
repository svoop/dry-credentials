gem 'minitest'

require 'debug'
require 'pathname'

require 'minitest/autorun'
require Pathname(__dir__).join('..', 'lib', 'dry-credentials')

require 'minitest/sound'
Minitest::Sound.success = Pathname(__dir__).join('sounds', 'success.mp3').to_s
Minitest::Sound.failure = Pathname(__dir__).join('sounds', 'failure.mp3').to_s

require 'minitest/focus'

class MiniTest::Spec
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

  def self.init!
    instance_variable_set(:'@__credentials_extension__', nil)
    credentials do
      env 'test'
      dir fixtures_path.join('encrypted').to_s
    end
    self
  end
end
