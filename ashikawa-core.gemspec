# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ashikawa-core/version"

Gem::Specification.new do |gem|
  gem.name        = "ashikawa-core"
  gem.version     = Ashikawa::Core::VERSION
  gem.authors     = ["moonglum", "EinLama"]
  gem.email       = ["me@moonglum.net", "tobias.eilert@me.com"]
  gem.homepage    = "http://triagens.github.com/ashikawa-core"
  gem.summary     = "Ashikawa Core is a wrapper around the ArangoDB REST API"
  gem.description = "Ashikawa Core is a wrapper around the ArangoDB REST API. It provides low level access and will be used in different ArangoDB ODMs and other tools."

  gem.required_ruby_version = '>= 1.8.7'
  gem.requirements << "ArangoDB, v1.2"

  gem.rubyforge_project = "ashikawa-core"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  # Runtime Dependencies
  gem.add_dependency "rest-client", "~> 1.6.7"
  gem.add_dependency "json", "~> 1.7.7"

  # Development Dependencies
  gem.add_development_dependency "webmock", "~> 1.9.3"
end
