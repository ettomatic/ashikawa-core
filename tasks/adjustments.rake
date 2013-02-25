# Remove some tasks defined by devtools to redefine them

Rake::Task["spec"].clear
Rake::Task["ci:metrics"].clear
Rake::Task["ci"].clear

## Specs
# Difference to Devtools:
# * Acceptance, no integration tests
# * Special Case: ArangoDB needed for Acceptance Tests


desc 'Run all specs'
task :spec => %w[ spec:unit spec:acceptance ]

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

## Metrics
# Differences to Devtools:
# * Do not run mutant and reek, they do not pass yet
# * On the CI, ArangoDB is already running so use the special acceptance task

namespace :ci do
  desc 'Run metrics'
  task :metrics => %w[ metrics:verify_measurements metrics:flog metrics:flay metrics:reek metrics:roodi ]
end

desc 'Run metrics with Mutant'
task :ci => %w[ spec:unit spec:acceptance_with_running_arangodb ]
