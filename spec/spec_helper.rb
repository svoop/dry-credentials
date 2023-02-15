gem 'minitest'

require 'debug'
require 'pathname'

require 'minitest/autorun'
require Pathname(__dir__).join('..', 'lib', 'dry', 'credentials')

require 'minitest/sound'
Minitest::Sound.success = Pathname(__dir__).join('sounds', 'success.mp3').to_s
Minitest::Sound.failure = Pathname(__dir__).join('sounds', 'failure.mp3').to_s

require 'minitest/focus'

class MiniTest::Spec
  class << self
    alias_method :context, :describe
  end
end
