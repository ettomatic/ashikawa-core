$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "ashikawa-core"

ARANGO_HOST = "http://localhost:8529"
