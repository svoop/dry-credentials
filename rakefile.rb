require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create(:test) do |t|
  t.test_globs = ["spec/**/*_spec.rb"]
  t.verbose = false
  t.warning = !ENV['RUBYOPT']&.match?(/-W0/)
end

namespace :yard do
  desc "Run local YARD documentation server"
  task :server do
    `rm -rf ./.yardoc`
    Thread.new do
      sleep 2
      `open http://localhost:8808`
    end
    `yard server -r`
  end
end

Rake::Task[:test].enhance do
  if ENV['RUBYOPT']&.match?(/-W0/)
    puts "⚠️  Ruby warnings are disabled, remove -W0 from RUBYOPT to enable."
  end
end

task default: :test
