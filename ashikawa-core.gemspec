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

  gem.add_dependency "faraday", "~> 0.8.6"
  gem.add_dependency "json", "~> 1.7.7"
  gem.add_dependency "null_logger", "~> 0.0.1"

  # Set to 2.8.2 because of Devtools
  # Needs an upgrade, because of an error in this version
  gem.add_dependency "backports", "~> 2.8.2"
end
