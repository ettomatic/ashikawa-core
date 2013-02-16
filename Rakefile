#!/usr/bin/env rake
require 'devtools'
require "bundler/gem_tasks"

Devtools.init

namespace :spec do
  desc "Run the acceptance tests. Requires ArangoDB to be running."
  RSpec::Core::RakeTask.new(:acceptance_with_running_arangodb) do |spec|
    spec.pattern = "spec/acceptance/*_spec.rb"
  end

  desc "Run the acceptance tests. Requires ArangoDB."
  RSpec::Core::RakeTask.new(:acceptance) do |spec|
    spec.rspec_opts = "--require acceptance/arango_helper.rb"
    spec.pattern = "spec/acceptance/*_spec.rb"
  end

  desc "Run the authentication acceptance tests. Requires ArangoDB."
  RSpec::Core::RakeTask.new(:acceptance_auth) do |spec|
    spec.rspec_opts = "--require acceptance_auth/arango_helper.rb"
    spec.pattern = "spec/acceptance_auth/*_spec.rb"
  end
end

# desc "Run Unit Tests - no ArangoDB required"
# task :ci => ["spec:unit", "spec:acceptance_with_running_arangodb", "metrics:all"]

# desc "Run all tests and verify documentation - ArangoDB required"
# task :default => ["spec:all", "metrics:all"]
