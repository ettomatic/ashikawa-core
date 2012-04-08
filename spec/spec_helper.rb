$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

# For HTTP Testing
require 'webmock/rspec'
require 'json'

# Helper to simulate Server Responses. Parses the fixtures in the spec folder
def server_response(path)
  return JSON.parse(File.readlines("spec/fixtures/#{path}.json").join)
end