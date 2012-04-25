$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "rest-client"
require "json"
require "ashikawa-core"

RSpec.configure do |config|
  raise "Could not find avocado. Please install it or check if it is in your path." if `which avocado` == ""
  
  database_directory = "/tmp/ashikawa-integration"
  avocado_process = false
  
  config.before(:suite) do
    puts "Starting AvocadoDB"
    process_id = $$
    
    Dir.mkdir database_directory unless Dir.exists? database_directory
    avocado_process = IO.popen("avocado #{database_directory} --watch-process #{process_id}")
    
    sleep 2 # Wait for Avocado to start up
  end
  
  config.after(:suite) do
    puts
    puts "Shutting down AvocadoDB"
    
    Process.kill "INT", avocado_process.pid
    sleep 2  # Wait for Avocado to shut down
    avocado_process.close
    
    `rm -r #{database_directory}/*`
  end
end