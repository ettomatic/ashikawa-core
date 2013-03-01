require "ashikawa-core/exceptions/client_error/resource_not_found/collection_not_found"
require "ashikawa-core/collection"
require "ashikawa-core/connection"
require "ashikawa-core/cursor"
require "forwardable"

module Ashikawa
  module Core
    # Configuration of Ashikawa::Core
    Configuration = Struct.new(:url, :connection)

    # An ArangoDB database
    class Database
      COLLECTION_TYPES = {
        :document => 2,
        :edge => 3
      }

      extend Forwardable

      # Delegate sending requests to the connection
      def_delegator :@connection, :send_request
      def_delegator :@connection, :host
      def_delegator :@connection, :port
      def_delegator :@connection, :scheme
      def_delegator :@connection, :authenticate_with

      # Initializes the connection to the database
      #
      # @api public
      # @example Access a Database by providing the URL
      #  database = Ashikawa::Core::Database.new("http://localhost:8529")
      # @example Access a Database by providing a Connection
      #  connection = Connection.new("http://localhost:8529")
      #  database = Ashikawa::Core::Database.new connection
      def initialize()
        configuration = Ashikawa::Core::Configuration.new
        yield(configuration)

        if !configuration.url.nil?
          @connection = Ashikawa::Core::Connection.new(configuration.url)
        elsif !configuration.connection.nil?
          @connection = configuration.connection
        #else
          #throw ArgumentError
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
      # @option opts [Boolean] :content_type What kind of content should the collection have? Default is :document
      # @return [Collection]
      # @api public
      # @example Create a new, volatile collection
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   database.create_collection("a", :isVolatile => true) # => #<Collection name="a">
      def create_collection(collection_identifier, opts={})
        params = { :name => collection_identifier }
        params[:isVolatile] = true if opts[:is_volatile] == true
        params[:type] = COLLECTION_TYPES[opts[:content_type]] if opts.has_key?(:content_type)
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
      def collection(collection_identifier)
        begin
          response = send_request("collection/#{collection_identifier}")
        rescue CollectionNotFoundException
          response = send_request("collection", :post => { :name => collection_identifier })
        end

        Ashikawa::Core::Collection.new(self, response)
      end

      alias :[] :collection

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
