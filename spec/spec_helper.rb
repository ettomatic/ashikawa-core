$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

# For HTTP Testing
require 'webmock/rspec'

def server_response(path)
  return File.readlines("spec/fixtures/#{path}.json").join
end