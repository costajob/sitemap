# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sitemap/version'

Gem::Specification.new do |s|
  s.name          = "sitemap"
  s.version       = Sitemap::VERSION
  s.authors       = ["costajob"]
  s.email         = ["costajob@gmail.com"]
  s.summary       = %q{Create XML sitemap by accessing data from MySQL}
  s.homepage      = "https://github.com/costajob/sitemap.git"
  s.license       = "MIT"
  s.required_ruby_version = ">= 1.9.2"
  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|s|features)/}) }
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "builder", "~> 3.2.2"
  s.add_runtime_dependency "mysql2", "~> 0.4.3"
  s.add_runtime_dependency "sequel", "~> 4.32.0"
  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rr", "~> 1.1.2"
end
