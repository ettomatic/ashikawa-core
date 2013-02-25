$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

if defined? version and version != '1.8.7'
  require 'simplecov'
  SimpleCov.start do
      add_filter "spec/"
  end
  SimpleCov.minimum_coverage 100
end

# For HTTP Testing
require 'json'

# Helper to simulate Server Responses. Parses the fixtures in the spec folder
def server_response(path)
  return JSON.parse(File.readlines("spec/fixtures/#{path}.json").join)
end
