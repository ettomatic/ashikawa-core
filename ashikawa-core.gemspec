# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ashikawa-core/version"

IS_RUBY_18 = defined? VERSION and VERSION == '1.8.7' unless defined? IS_RUBY_18
IS_JRUBY = defined? PLATFORM and PLATFORM == 'java' unless defined? IS_JRUBY

Gem::Specification.new do |gem|
  gem.name        = "ashikawa-core"
  gem.version     = Ashikawa::Core::VERSION
  gem.authors     = ["moonglum", "EinLama"]
  gem.email       = ["me@moonglum.net", "tobias.eilert@me.com"]
  gem.homepage    = "http://triagens.github.com/ashikawa-core"
  gem.summary     = "Ashikawa Core is a wrapper around the ArangoDB REST API"
  gem.description = "Ashikawa Core is a wrapper around the ArangoDB REST API. It provides low level access and will be used in different ArangoDB ODMs."

  gem.required_ruby_version = '>= 1.9.2'
  gem.requirements << "ArangoDB, v1.1.2"

  gem.rubyforge_project = "ashikawa-core"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  # Runtime Dependencies
  gem.add_dependency "rest-client", "~> 1.6.7"
  gem.add_dependency "json", "~> 1.7.7" if IS_RUBY_18 or IS_JRUBY
  gem.add_dependency "backports", "~> 2.6.7" if IS_RUBY_18

  # Development Dependencies
  gem.add_development_dependency "webmock", "~> 1.9.0"
  gem.add_development_dependency "rb-fsevent", "~> 0.9.2"
end
