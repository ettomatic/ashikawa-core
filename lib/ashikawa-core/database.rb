require "ashikawa-core/collection"
require "ashikawa-core/connection"

module Ashikawa
  module Core
    # Represents an ArangoDB database in Ruby
    class Database
      # Initializes the connection to the database
      # 
      # @param [Connection, String] connection A Connection object or a String to create a Connection object.
      # @api public
      # @example Access a Database by providing the URL
      #  database = Ashikawa::Core::Database.new "http://localhost:8529"
      # @example Access a Database by providing a Connection
      #  connection = Connection.new "http://localhost:8529"
      #  database = Ashikawa::Core::Database.new connection
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
      # @example Get the IP of the connection
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   database.ip # => http://localhost
      def ip
        @connection.ip
      end
      
      # The Port of the database
      # 
      # @return [Fixnum]
      # @api public
      # @example Get the port for the connection
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   database.port # => 8529
      def port
        @connection.port
      end
      
      # Returns a list of all collections defined in the database
      # 
      # @return [Array<Collection>]
      # @api public
      # @example Get an Array containing the Collections in the database
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   database["a"]
      #   database["b"]
      #   database.collections # => [ #<Collection name="a">, #<Collection name="b">]
      def collections
        server_response = @connection.send_request "/collection"
        server_response["collections"].map { |collection| Ashikawa::Core::Collection.new self, collection }
      end
      
      # Get or create a Collection based on name or ID
      # 
      # @param [String, Fixnum] collection_identifier The name or ID of the collection
      # @return [Collection]
      # @api public
      # @example Get a Collection from the database by name
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   database["a"] # => #<Collection name="a">
      # @example Get a Collection from the database by ID
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   database["7254820"] # => #<Collection id=7254820>
      def [](collection_identifier)
        begin
          server_response = @connection.send_request "/collection/#{collection_identifier}"
        rescue RestClient::ResourceNotFound
          server_response = @connection.send_request "/collection", post: { name: collection_identifier }
        end
        
        Ashikawa::Core::Collection.new self, server_response
      end
      
      # Sends a request to a given path (Prepends the api_string automatically)
      # 
      # @example Send a get request to the database
      #   connection.send_request('/collection/new_collection')
      # @example Send a post request to the database
      #   connection.send_request('/collection/new_collection', :post => { :name => 'new_collection' })
      # @param [String] path the path you wish to send a request to.
      # @param [Hash] method_params additional parameters for your request. Only needed if you want to send something other than a GET request.
      # @option method_params [Hash] :post POST data in case you want to send a POST request.
      # @return [Hash] parsed JSON response from the server
      # @api semipublic
      def send_request(path, method_params = {})
        @connection.send_request path, method_params
      end
    end
  end
end