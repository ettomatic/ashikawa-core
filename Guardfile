guard 'bundler' do
  watch(/^.+\.gemspec/)
end

guard 'rspec', :spec_paths => "spec/unit" do
  watch(%r{lib/.+\.rb})
  watch(%r{spec/.+\.rb})
end
