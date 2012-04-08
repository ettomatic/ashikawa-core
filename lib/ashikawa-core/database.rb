require "ashikawa-core/collection"
require "ashikawa-core/connection"

module Ashikawa
  module Core
    class Database
      # Initializes the connection to the database
      # 
      # @param [Connection] connection A connection object.
      def initialize(connection)
        @connection = connection
      end
      
      # The IP of the database
      def ip
        @connection.ip
      end
      
      # The Port of the database
      def port
        @connection.port
      end
      
      # Returns a list of all collections defined in the database
      # 
      # @return [Array<Collection>]
      def collections
        server_response = @connection.send_request "/collection"
        server_response["collections"].map { |collection| Ashikawa::Core::Collection.new self, collection }
      end
      
      # Get or create a Collection based on name or ID
      # 
      # @return [Collection]
      def [](collection_identifier)
        server_response = @connection.send_request "/collection/#{collection_identifier}"
        
        unless server_response['code'] == 200
          server_response = @connection.send_request "/collection/#{collection_identifier}", post: { name: collection_identifier}
        end
        
        Ashikawa::Core::Collection.new self, server_response
      end
      
      # Send a request to the connection object
      def send_request(path, method_params = {})
        @connection.send_request path, method_params
      end
    end
  end
end