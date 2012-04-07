require "ashikawa-core/collection"

require "rest-client"
require "json"

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
        @api_string = "#{connection_string}/_api"
      end
      
      def collections
        server_response = api_request "/collection"
        server_response["collections"].map { |collection| Ashikawa::Core::Collection.new collection["name"], id: collection["id"] }
      end
      
      def [](collection_identifier)
        server_response = api_request "/collection/#{collection_identifier}"
        Ashikawa::Core::Collection.new server_response["name"], id: server_response["id"]
      end
      
      private
      
      def api_request(path)
        path.gsub! /^\//,''
        
        JSON.parse RestClient.get("#{@api_string}/#{path}")
      end
    end
  end
end