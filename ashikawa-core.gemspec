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

  if defined? VERSION and VERSION == '1.8.7'
    gem.add_dependency "json", "~> 1.7.7"
    gem.add_dependency "backports", "~> 2.6.7"
  end

  # Runtime Dependencies (JRuby only)
  if defined? PLATFORM and PLATFORM == 'java'
    gem.add_dependency "json", "~> 1.7.5"
    gem.add_dependency "jruby-openssl", "~> 0.8.2"
  else
    # RedCarpet is not compatible with JRuby
    # It is only needed to generate the YARD Documentation
    gem.add_development_dependency "redcarpet", "~> 2.2.2"
  end

  # Development Dependencies
  gem.add_development_dependency "rake", "~> 10.0.3"
  gem.add_development_dependency "rspec", "~> 2.12.0"
  gem.add_development_dependency "yard", "~> 0.8.3"
  gem.add_development_dependency "webmock", "~> 1.9.0"
  gem.add_development_dependency "yardstick", "~> 0.8.0"
  gem.add_development_dependency "simplecov", "~> 0.7.1"

  if defined? VERSION and VERSION != '1.8.7'
    gem.add_development_dependency "cane", "~> 2.5.0"
    gem.add_development_dependency "roodi1.9", "~> 2.0.1"
  end

  # Do not update to version 3, it is currently not compatible with roodi1.9
  # see grsmv/roodi1.9#1
  gem.add_development_dependency "ruby_parser", "= 2.3.1"

  gem.add_development_dependency "guard", "~> 1.6.1"
  gem.add_development_dependency "guard-rspec", "~> 2.4.0"
  gem.add_development_dependency "guard-bundler", "~> 1.0.0"
  gem.add_development_dependency "rb-fsevent", "~> 0.9.2"
end
