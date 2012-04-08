require "ashikawa-core/collection"
require "ashikawa-core/connection"

module Ashikawa
  module Core
    class Database
      # The IP of the database
      attr_reader :ip
      
      # The Port of the database
      attr_reader :port
      
      # Initializes the connection with a connection string
      # 
      # @param [String] connection_string A string in the form of ip:port. For Example: http://localhost:8529
      def initialize(connection_string)
        @ip, @port = connection_string.scan(/(\S+):(\d+)/).first
        Ashikawa::Core::Connection.api_string = "#{connection_string}/_api"
      end
      
      # Returns a list of all collections defined in the database
      # 
      # @return [Array<Collection>]
      def collections
        server_response = Ashikawa::Core::Connection.request "/collection"
        server_response["collections"].map { |collection| Ashikawa::Core::Collection.new collection["name"], id: collection["id"] }
      end
      
      # Get or create a Collection based on name or ID
      # 
      # @return [Collection]
      def [](collection_identifier)
        server_response = Ashikawa::Core::Connection.request "/collection/#{collection_identifier}"
        
        unless server_response['code'] == 200
          server_response = Ashikawa::Core::Connection.request "/collection/#{collection_identifier}", post: { name: collection_identifier}
        end
        
        Ashikawa::Core::Collection.new server_response["name"], id: server_response["id"]
      end
    end
  end
end