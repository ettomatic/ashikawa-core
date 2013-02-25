require "ashikawa-core/exceptions/collection_not_found"
require "ashikawa-core/collection"
require "ashikawa-core/connection"
require "ashikawa-core/cursor"
require "forwardable"

module Ashikawa
  module Core
    # An ArangoDB database
    class Database
      extend Forwardable

      # Delegate sending requests to the connection
      def_delegator :@connection, :send_request
      def_delegator :@connection, :host
      def_delegator :@connection, :port
      def_delegator :@connection, :scheme
      def_delegator :@connection, :authenticate_with

      # Initializes the connection to the database
      #
      # @param [Connection, String] connection A Connection object or a String to create a Connection object.
      # @api public
      # @example Access a Database by providing the URL
      #  database = Ashikawa::Core::Database.new("http://localhost:8529")
      # @example Access a Database by providing a Connection
      #  connection = Connection.new("http://localhost:8529")
      #  database = Ashikawa::Core::Database.new connection
      def initialize(connection)
        if connection.class == String
          @connection = Ashikawa::Core::Connection.new(connection)
        else
          @connection = connection
        end
      end

      # Returns a list of all collections defined in the database
      #
      # @return [Array<Collection>]
      # @api public
      # @example Get an Array containing the Collections in the database
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   database["a"]
      #   database["b"]
      #   database.collections # => [ #<Collection name="a">, #<Collection name="b">]
      def collections
        response = send_request("collection")
        response["collections"].map { |collection| Ashikawa::Core::Collection.new(self, collection) }
      end

      # Create a Collection based on name
      #
      # @param [String] collection_identifier The desired name of the collection
      # @option opts [Boolean] :is_volatile Should the collection be volatile? Default is false
      # @return [Collection]
      # @api public
      # @example Create a new, volatile collection
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   database.create_collection("a", :isVolatile => true) # => #<Collection name="a">
      def create_collection(collection_identifier, opts={})
        params = { :name => collection_identifier }
        params[:isVolatile] = true if opts[:is_volatile] == true
        response = send_request("collection", :post => params)
        Ashikawa::Core::Collection.new(self, response)
      end

      # Get or create a Collection based on name or ID
      #
      # @param [String, Fixnum] collection_identifier The name or ID of the collection
      # @return [Collection]
      # @api public
      # @example Get a Collection from the database by name
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   database["a"] # => #<Collection name="a">
      # @example Get a Collection from the database by ID
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   database["7254820"] # => #<Collection id=7254820>
      def [](collection_identifier)
        begin
          response = send_request("collection/#{collection_identifier}")
        rescue CollectionNotFoundException
          response = send_request("collection", :post => { :name => collection_identifier })
        end

        Ashikawa::Core::Collection.new(self, response)
      end

      # Return a Query initialized with this database
      #
      # @return [Query]
      # @api public
      # @example Send an AQL query to the database
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   database.query.execute "FOR u IN users LIMIT 2" # => #<Cursor id=33>
      def query
        Query.new(self)
      end
    end
  end
end
