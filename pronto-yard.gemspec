
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pronto/yard/version'

Gem::Specification.new do |spec|
  spec.name          = 'pronto-yard'
  spec.version       = Pronto::Yard::VERSION
  spec.authors       = ['Christoph Lupprich']
  spec.email         = ['christoph@luppri.ch']

  spec.summary       = %q{Pronto runner that lints for YARD compliance}
  spec.homepage      = 'https://github.com/clupprich/pronto-yard'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency('pronto', '~> 0.11.0')
  spec.add_runtime_dependency('yard-junk', '~> 0.0.9')

  spec.add_development_dependency 'bundler', '~> 2.3.19'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
end
