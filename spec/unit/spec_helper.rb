$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

# Helper to simulate Server Responses. Parses the fixtures in the spec folder
require 'json'
def server_response(path)
  return JSON.parse(File.readlines("spec/fixtures/#{path}.json").join)
end

ARANGO_HOST = "http://localhost:8529"
