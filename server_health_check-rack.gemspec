# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'server_health_check_rack/version'

Gem::Specification.new do |spec|
  spec.name          = "server_health_check-rack"
  spec.version       = ServerHealthCheckRack::VERSION
  spec.authors       = ["Mike Virata-Stone"]
  spec.email         = ["mjstone@on-site.com"]

  spec.summary       = %q{Healthcheck for Rack apps.}
  spec.description   = %q{Health check for Rack apps checking things like active record, redis, and AWS.}
  spec.homepage      = "https://github.com/on-site/server_health_check-rack"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(lib|exe|CODE_OF_CONDUCT|LICENSE)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "server_health_check", "~> 1.0", ">= 1.0.1"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
