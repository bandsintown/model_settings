# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'model_settings/version'

Gem::Specification.new do |spec|
  spec.name          = 'model_settings'
  spec.version       = ModelSettings::VERSION
  spec.authors       = ['Fernando Castellanos']
  spec.email         = ['fcastellanos@bandsintown.com']
  spec.summary       = %q{ Gem for storing arbitrary settings for models. }
  spec.description   = %q{ Allows us to easily add new settings to a model without having to run DB migrations. }
  spec.homepage      = 'https://github.com/bandsintown/model_settings'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_development_dependency 'rspec', '~> 2.6'
  spec.add_development_dependency 'shoulda-matchers', '~> 1.0.0'
  spec.add_development_dependency 'fivemat'
  spec.add_development_dependency 'pry', '=0.9.12.6'
  spec.add_development_dependency 'activerecord', '=2.3.18'
  spec.add_development_dependency 'activesupport', '=2.3.18'
  spec.add_development_dependency('sqlite3')
end
