require "ashikawa-core/collection"
require "ashikawa-core/connection"

module Ashikawa
  module Core
    class Database
      # Initializes the connection to the database
      # 
      # @param [Connection, String] connection A Connection object or a String to create a Connection object.
      # @api public
      def initialize(connection)
        if connection.class == String
          @connection = Ashikawa::Core::Connection.new connection
        else
          @connection = connection
        end
      end
      
      # The IP of the database
      # 
      # @return [String]
      # @api public
      def ip
        @connection.ip
      end
      
      # The Port of the database
      # 
      # @return [Fixnum]
      # @api public
      def port
        @connection.port
      end
      
      # Returns a list of all collections defined in the database
      # 
      # @return [Array<Collection>]
      # @api public
      def collections
        server_response = @connection.send_request "/collection"
        server_response["collections"].map { |collection| Ashikawa::Core::Collection.new self, collection }
      end
      
      # Get or create a Collection based on name or ID
      # 
      # @return [Collection]
      # @api public
      def [](collection_identifier)
        begin
          server_response = @connection.send_request "/collection/#{collection_identifier}"
        rescue RestClient::ResourceNotFound
          server_response = @connection.send_request "/collection", post: { name: collection_identifier }
        end
        
        Ashikawa::Core::Collection.new self, server_response
      end
      
      # Send a request to the connection object
      # 
      # @return [String] Server Reponse
      # @api semipublic
      def send_request(path, method_params = {})
        @connection.send_request path, method_params
      end
    end
  end
end