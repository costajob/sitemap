# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sitemap/version'

Gem::Specification.new do |spec|
  spec.name          = "sitemap"
  spec.version       = Sitemap::VERSION
  spec.authors       = ["costajob"]
  spec.email         = ["costajob@gmail.com"]

  spec.summary       = %q{Create XML sitemap by accessing data from MySQL}
  spec.homepage      = "https://github.com/costajob/sitemap.git"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "builder", "~> 3.2.2"
  spec.add_runtime_dependency "mysql2", "~> 0.4.3"
  spec.add_runtime_dependency "sequel", "~> 4.32.0"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rr", "~> 1.1.2"
end
