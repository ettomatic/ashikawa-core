$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "rest-client"
require "json"
require "ashikawa-core"

RSpec.configure do |config|
  raise "Could not find arango. Currently searching for avocado, because the renaming is not done. Please install it or check if it is in your path." if `which avocado` == ""
  
  database_directory = "/tmp/ashikawa-integration"
  arango_process = false
  
  config.before(:suite) do
    puts "Starting ArangoDB"
    process_id = $$
    
    Dir.mkdir database_directory unless Dir.exists? database_directory
    arango_process = IO.popen("avocado #{database_directory} --watch-process #{process_id}")
    
    sleep 2 # Wait for Arango to start up
  end
  
  config.after(:suite) do
    puts
    puts "Shutting down ArangoDB"
    
    Process.kill "INT", arango_process.pid
    sleep 2  # Wait for Arango to shut down
    arango_process.close
    
    `rm -r #{database_directory}/*`
  end
end