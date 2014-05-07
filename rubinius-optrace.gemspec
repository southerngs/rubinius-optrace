# coding: utf-8

require './lib/rubinius/optrace/version'

Gem::Specification.new do |spec|
  spec.name         = "rubinius-optrace"
  spec.version      = Rubinius::Optrace::VERSION
  spec.authors      = ["Gabriel Southern"]
  spec.email        = ["southerngs@gmail.com"]
  spec.description   = %q{Rubinius optrace tool.}
  spec.summary       = %q{Rubinius optrace tool.}
  spec.homepage      = "https://github.com/southerngs/rubinius-optrace"
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.extensions    = ["ext/rubinius/optrace/extconf.rb"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
