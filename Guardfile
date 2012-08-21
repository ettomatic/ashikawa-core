guard 'bundler' do
  watch(/^.+\.gemspec/)
end

guard 'yard' do
  watch(%r{lib/.+\.rb})
end

guard 'rspec', :version => 2, :spec_paths => "spec/unit" do
  watch(%r{lib/.+\.rb})
  watch(%r{spec/.+\.rb})
end

guard 'rspec', :version => 2, :spec_paths => "spec/integration" do
  watch(%r{lib/.+\.rb})
  watch(%r{spec/.+\.rb})
end

