# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pvimpact/greenbutton/version'

Gem::Specification.new do |spec|
  spec.name          = 'pvimpact-greenbutton'
  spec.version       = PVImpactGreenButton::VERSION
  spec.authors       = ['albertwang']
  spec.email         = []
  spec.summary       = %q{Library to work with Green Button data.}
  spec.description   = %q{This library provides functionality to retrieve Green Button XML formatted data, process the data, persist it in database and return data as Ruby objects.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'pg'
  spec.add_dependency 'faraday'
  spec.add_dependency 'greenbutton'
  spec.add_dependency 'datamapper'
  spec.add_dependency 'dm-postgres-adapter'
  spec.add_dependency 'dm-zone-types'
  spec.add_dependency 'ruby-enum'
  spec.add_dependency 'configurations'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'database_cleaner'

end
