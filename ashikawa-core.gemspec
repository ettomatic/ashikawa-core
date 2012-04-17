# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ashikawa-core/version"

Gem::Specification.new do |gem|
  gem.name        = "ashikawa-core"
  gem.version     = Ashikawa::Core::VERSION
  gem.authors     = ["moonglum", "EinLama"]
  gem.email       = ["me@moonglum.net", "tobias.eilert@me.com"]
  gem.homepage    = ""
  gem.summary     = "Ashikawa Core is a Wrapper around the AvocadoDB Rest API"
  gem.description = "Ashikawa Core is a Wrapper around the AvocadoDB Rest API. It provides low level access and will be used in different AvocadoDB ODMs."
  
  gem.required_ruby_version = '>= 1.9.2'
  gem.requirements << "AvocadoDB"
  
  gem.rubyforge_project = "ashikawa-core"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  # Runtime Dependencies
  gem.add_dependency "rest-client", "~> 1.6.7"
  
  # Runtime Dependencies (JRuby only)
  if defined? PLATFORM and PLATFORM == 'java'
    gem.add_dependency "json", "~> 1.6.6"
    gem.add_dependency "jruby-openssl", "~> 0.7.6.1"
  end
  
  # Development Dependencies
  gem.add_development_dependency "rake", "~> 0.9.2.2"
  gem.add_development_dependency "rspec", "~> 2.9.0"
  gem.add_development_dependency "yard", "~> 0.7.5"
  gem.add_development_dependency "webmock", "~> 1.8.6"
  gem.add_development_dependency "yardstick", "~> 0.4.0"
end
