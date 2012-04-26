#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec"
require "rspec/core/rake_task"
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'


namespace :spec do
  desc "Run the integration tests. Requires AvocadoDB."
  RSpec::Core::RakeTask.new(:integration) do |spec|
    spec.pattern = "spec/integration/*_spec.rb"
  end
  
  desc "Run the unit tests"
  RSpec::Core::RakeTask.new(:unit) do |spec|
    spec.pattern = "spec/unit/*_spec.rb"
  end
  
  desc "Run all tests. Requires AvocadoDB"
  task :all => [:integration, :unit]
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

desc "Run Unit Tests and verify documentation - no AvocadoDB required"
task :ci => ["spec:unit", "yard:verify"]

desc "Run all tests and verify documentation - AvocadoDB required"
task :default => ["spec:all", "yard:verify"]