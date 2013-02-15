#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec"
require "rspec/core/rake_task"
require "yardstick/rake/measurement"
require "yardstick/rake/verify"

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

  desc "Run the unit tests"
  RSpec::Core::RakeTask.new(:unit) do |spec|
    spec.pattern = "spec/unit/*_spec.rb"
  end

  desc "Run all tests. Requires ArangoDB"
  task :all => [:acceptance, :unit]
end

desc "check if gems are up to date"
task :dependencies do
  dependency_status = `bundle outdated`
  if dependency_status.include? "up to date"
    puts "Dependencies up to date."
  else
    puts dependency_status
    exit(1)
  end
end

namespace :yard do
  Yardstick::Rake::Measurement.new(:report) do |measurement|
    measurement.output = 'report/measurement.txt'
  end

  Yardstick::Rake::Verify.new(:verify) do |verify|
    verify.threshold = 100
  end

  desc "generate the documentation"
  task :generate do
    `yard`
  end

  desc "start the documentation server on port 8808"
  task :server do
    `yard server --reload`
  end

  desc "get statistics on the yard documentation"
  task :stats do
    `yard stats`
  end
end

namespace :metrics do
  metric_tasks = []

  begin
    require 'cane/rake_task'

    desc "Run cane to check quality metrics"
    Cane::RakeTask.new(:cane) do |cane|
      cane.abc_max = 12
      cane.style_measure = 140
      cane.style_glob = "{app,lib}/**/*.rb"
    end

    metric_tasks << :cane
  rescue LoadError
    warn "cane not available, quality task not provided."
  end

  begin
    require "roodi"
    require "roodi_task"
    RoodiTask.new do |roodi|
      roodi.patterns = %w(lib/**/*.rb spec/**/*.rb)
    end
    metric_tasks << :roodi
  rescue LoadError
    warn "roodi not available, quality task not provided."
  end

  task :all => metric_tasks
end

desc "Run Unit Tests - no ArangoDB required"
# task :ci => ["spec:unit", "yard:verify"]
task :ci => ["spec:unit", "spec:acceptance_with_running_arangodb", "metrics:all"]

desc "Run all tests and verify documentation - ArangoDB required"
# task :default => ["spec:all", "yard:verify"]
task :default => ["spec:all", "metrics:all"]
