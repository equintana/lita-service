# frozen_string_literal: true
Gem::Specification.new do |spec|
  spec.name          = 'lita-service'
  spec.version       = '0.1.0'
  spec.authors       = ['Erlinis Quintana']
  spec.email         = ['erlinis.quintana@gmail.com']
  spec.description   = 'Plugin to create a service'
  spec.summary       = 'Plugin to create a service'
  spec.homepage      = 'https://github.com/equintana/lita-service'
  spec.license       = 'Open-Source License'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '>= 4.7'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov', '>=0.9.2'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rubocop', '~> 0.44.1'
end
