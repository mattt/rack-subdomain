# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack-subdomain"

Gem::Specification.new do |s|
  s.name        = "rack-subdomain"
  s.authors     = ["Mattt Thompson", "Piotr Sarnacki"]
  s.email       = "m@mattt.me"
  s.homepage    = "http://github.com/mattt/rack-subdomain"
  s.version     = Rack::Subdomain::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "rack-subdomain"
  s.description = "Rack middleware to route requests with subdomains to specified routes with substitutions"

  s.add_runtime_dependency "rack", ">= 1.2.0", "<= 2.0.0"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest",  "~> 2.11"
  s.add_development_dependency "rack-test", "~> 0.6"

  s.files         = Dir["./**/*"].reject { |file| file =~ /\.\/(bin|log|pkg|script|spec|test|vendor)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
