# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'model_settings/version'

Gem::Specification.new do |spec|
  spec.name          = 'model_settings'
  spec.version       = ModelSettings::VERSION
  spec.authors       = ['Christopher J. Bottaro']
  spec.email         = ['cjbottaro@alumni.cs.utexas.edu']
  spec.summary       = %q{ Gem for storing arbitrary settings for models. }
  spec.description   = %q{ Allows us to easily add new settings to a model without having to run DB migrations. }
  spec.homepage      = 'https://github.com/bandsintown/model_settings'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_runtime_dependency('rails', '~> 2.3')

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency('sqlite3')
end
