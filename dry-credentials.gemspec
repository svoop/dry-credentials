# frozen_string_literal: true

require_relative 'lib/dry/credentials/version'

Gem::Specification.new do |spec|
  spec.name        = 'dry-credentials'
  spec.version     = Dry::Credentials::VERSION
  spec.summary     = 'A mixin to use encrypted credentials in your classes'
  spec.description = <<~END
    Manage and deploy secrets (access keys, API tokens etc) in encrypted
    files which can safely be committed to the code repository. To decrypt and
    and use them, only one environment variable containing the corresponding key
    is required.

    While similar to ActiveSupport::EncryptedConfiguration, this lightweight
    implementation introduces as few dependencies as necessary.
  END
  spec.authors     = ['Sven Schwyn']
  spec.email       = ['ruby@bitcetera.com']
  spec.homepage    = 'https://github.com/svoop/dry-credentials'
  spec.license     = 'MIT'

  spec.metadata = {
    'homepage_uri'      => spec.homepage,
    'changelog_uri'     => 'https://github.com/svoop/dry-credentials/blob/main/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/svoop/dry-credentials',
    'documentation_uri' => 'https://www.rubydoc.info/gems/dry-credentials',
    'bug_tracker_uri'   => 'https://github.com/svoop/dry-credentials/issues'
  }

  spec.files         = Dir['lib/**/*']
  spec.require_paths = %w(lib)

  spec.cert_chain  = ["certs/svoop.pem"]
  spec.signing_key = File.expand_path(ENV['GEM_SIGNING_KEY']) if ENV['GEM_SIGNING_KEY']

  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.rdoc_options    += [
    '--title', 'Dry::Credentials',
    '--main', 'README.md',
    '--line-numbers',
    '--inline-source',
    '--quiet'
  ]

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-flash'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'yard'
end
