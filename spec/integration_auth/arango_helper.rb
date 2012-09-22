RSpec.configure do |config|
  raise "Could not find arangod. Please install it or check if it is in your path." if `which arangod` == ""

  database_directory = "/tmp/ashikawa-integration-auth"
  arango_process = false

  config.before(:suite) do
    puts "Generating user with password"
    `arango-password --database #{database_directory} testuser testpassword`

    puts "Starting ArangoDB with authentication enabled"
    process_id = $$

    Dir.mkdir database_directory unless Dir.exists? database_directory
    arango_process = IO.popen("arangod #{database_directory} --server.http-auth yes --watch-process #{process_id}")

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
