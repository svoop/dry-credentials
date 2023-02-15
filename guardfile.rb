clearing :on

guard :minitest do
  watch(%r{^spec/(.+)_spec\.rb})
  watch(%r{^lib/(.+)\.rb}) { "spec/lib/#{_1[1]}_spec.rb" }
  watch('lib/dry/credentials/config.rb') { 'spec/lib/dry/credentials_spec.rb' }
  watch(%r{^spec/spec_helper\.rb}) { 'spec' }
end
