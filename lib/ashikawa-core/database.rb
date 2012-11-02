require "ashikawa-core/collection"
require "ashikawa-core/connection"
require "ashikawa-core/cursor"
require "forwardable"

module Ashikawa
  module Core
    # Represents an ArangoDB database in Ruby
    class Database
      extend Forwardable

      # Delegate sending requests to the connection
      delegate send_request: :@connection
      delegate host: :@connection
      delegate port: :@connection
      delegate scheme: :@connection
      delegate authenticate_with: :@connection

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
        server_response = send_request "/collection"
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
          server_response = send_request "/collection/#{collection_identifier}"
        rescue RestClient::ResourceNotFound
          server_response = send_request "/collection", post: { name: collection_identifier }
        end

        Ashikawa::Core::Collection.new self, server_response
      end

      # Return a Query initialized with this database
      #
      # @return [Query]
      # @api public
      def query
        Query.new database: self
      end
    end
  end
end
