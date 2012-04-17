#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec"
require "rspec/core/rake_task"
require 'yardstick/rake/measurement'
require 'yardstick/rake/verify'

RSpec::Core::RakeTask.new("spec") do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

namespace :yard do
  Yardstick::Rake::Measurement.new(:report) do |measurement|
    measurement.output = 'report/measurement.txt'
  end

  Yardstick::Rake::Verify.new(:verify) do |verify|
    verify.threshold = 100
  end
end


task :default => :spec