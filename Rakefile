#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec"
require "rspec/core/rake_task"
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'


namespace :spec do
  desc "Run the integration tests. Requires AvocadoDB."
  RSpec::Core::RakeTask.new(:integration) do |spec|
    raise "Could not find avocado. Please install it or check if it is in your path." if `which avocado` == ""
    spec.pattern = "spec/integration/*_spec.rb"
  end
  
  desc "Run the unit tests"
  RSpec::Core::RakeTask.new(:unit) do |spec|
    spec.pattern = "spec/unit/*_spec.rb"
  end
  
  desc "Run all tests. Requires AvocadoDB"
  task :all => [:integration, :unit] do
  end
end

namespace :yard do
  desc "Report on the Documentation Quality. Writes report/measurement.txt"
  Yardstick::Rake::Measurement.new(:report) do |measurement|
    measurement.output = 'report/measurement.txt'
  end
  
  desc "Verifies the documentation"
  Yardstick::Rake::Verify.new(:verify) do |verify|
    verify.threshold = 100
  end
end

task :default => "spec:unit"