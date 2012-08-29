require "ashikawa-core/document"
require "ashikawa-core/index"
require "ashikawa-core/cursor"
require "forwardable"

module Ashikawa
  module Core
    # Represents a certain Collection within the Database
    class Collection
      extend Forwardable

      # The name of the collection, must be unique
      #
      # @return [String]
      # @api public
      # @example Change the name of a collection
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.name # => "example_1"
      #   collection.name = "example_2"
      #   collection.name # => "example_2"
      attr_reader :name

      # The ID of the collection. Is set by the database and unique
      #
      # @return [Fixnum]
      # @api public
      # @example Get the id of the collection
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.id #=> 4588
      attr_reader :id

      # Sending requests is delegated to the database
      delegate send_request: :@database

      # Create a new Collection object with a name and an optional ID
      #
      # @param [Database] database The database the connection belongs to
      # @param [Hash] raw_collection The raw collection returned from the server
      # @api public
      # @example Create a Collection object from scratch
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      def initialize(database, raw_collection)
        @database = database
        @name = raw_collection['name'] if raw_collection.has_key? 'name'
        @id  = raw_collection['id'].to_i if raw_collection.has_key? 'id'
        @status = raw_collection['status'].to_i if raw_collection.has_key? 'status'
      end

      # Change the name of the collection
      #
      # @param [String] new_name New Name
      # @return [String] New Name
      # @api public
      # @example Change the name of a collection
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.name # => "example_1"
      #   collection.name = "example_2"
      #   collection.name # => "example_2"
      def name=(new_name)
        send_request_for_this_collection "/rename", put: { "name" => new_name }
        @name = new_name
      end

      # Checks if the collection is new born
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection new born?
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.new_born? #=> false
      def new_born?
        @status == 1
      end

      # Checks if the collection is unloaded
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection unloaded?
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.unloaded? #=> false
      def unloaded?
        @status == 2
      end

      # Checks if the collection is loaded
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection loaded?
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.loaded? #=> true
      def loaded?
        @status == 3
      end

      # Checks if the collection is in the process of being unloaded
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection unloaded?
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.being_unloaded? #=> false
      def being_unloaded?
        @status == 4
      end

      # Checks if the collection is corrupted
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection corrupted?
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.corrupted? #=> false
      def corrupted?
        @status > 5
      end

      # Does the document wait until the data has been synchronised to disk?
      #
      # @return [Boolean]
      # @api public
      # @example Does the collection wait for file synchronization?
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.wait_for_sync? #=> false
      def wait_for_sync?
        server_response = send_request_for_this_collection "/properties"
        server_response["waitForSync"]
      end

      # Change if the document will wait until the data has been synchronised to disk
      #
      # @return [String] Response from the server
      # @api public
      # @example Tell the collection to wait for file synchronization
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.wait_for_sync = true
      def wait_for_sync=(new_value)
        send_request_for_this_collection "/properties", put: { "waitForSync" => new_value }
      end

      # Returns the number of documents in the collection
      #
      # @return [Fixnum] Number of documents
      # @api public
      # @example How many documents are in the collection?
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.length # => 0
      def length
        server_response = send_request_for_this_collection "/count"
        server_response["count"]
      end

      # Return a figure for the collection
      #
      # @param [Symbol] figure_type The figure you want to know:
      #     * :datafiles_count - the number of active datafiles
      #     * :alive_size - the total size in bytes used by all living documents
      #     * :alive_count - the number of living documents
      #     * :dead_size - the total size in bytes used by all dead documents
      #     * :dead_count - the number of dead documents
      # @return [Fixnum] The figure you requested
      # @api public
      # @example Get the datafile count for a collection
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.figure :datafiles_count #=> 0
      def figure(figure_type)
        server_response = send_request_for_this_collection "/figures"
        figure_area, figure_name = figure_type.to_s.split "_"
        server_response["figures"][figure_area][figure_name]
      end

      # Deletes the collection
      #
      # @return [String] Response from the server
      # @api public
      # @example Delete a collection
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.delete
      def delete
        send_request_for_this_collection "", delete: {}
      end

      # Load the collection into memory
      #
      # @return [String] Response from the server
      # @api public
      # @example Load a collection into memory
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.load
      def load
        send_request_for_this_collection "/load", put: {}
      end

      # Load the collection into memory
      #
      # @return [String] Response from the server
      # @api public
      # @example Unload a collection into memory
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.unload
      def unload
        send_request_for_this_collection "/unload", put: {}
      end

      # Delete all documents from the collection
      #
      # @return [String] Response from the server
      # @api public
      # @example Remove all documents from a collection
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.truncate!
      def truncate!
        send_request_for_this_collection "/truncate", put: {}
      end

      # Retrieves all documents for this collection
      #
      # @note It is advised to NOT use this method due to possible HUGE data amounts requested
      # @option options [Integer] :limit limit the maximum number of queried and returned elements.
      # @option options [Integer] :skip skip the first <n> documents of the query.
      # @return [Cursor]
      # @api public
      # @example Get an array with all documents
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.all # => #<Cursor id=33>
      def all(options={})
        send_simple_query "/simple/all", options, [:limit, :skip]
      end

      # Looks for documents in the collection which match the given criteria
      #
      # @option options [Hash] :example a Hash with data matching the documents you are looking for.
      # @option options [Integer] :limit limit the maximum number of queried and returned elements.
      # @option options [Integer] :skip skip the first <n> documents of the query.
      # @return [Cursor]
      # @api public
      # @example Find all documents in the collection that are red
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.by_example example: { "color" => "red"} # => #<Cursor id=2444>
      def by_example(options={})
        send_simple_query "/simple/by-example", options, [:limit, :skip, :example]
      end

      # Looks for one document in the collection which matches the given criteria
      #
      # @param [Hash] example a Hash with data matching the document you are looking for.
      # @return [Document]
      # @api public
      # @example Find one document in the collection that is red
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.first_example { "color" => "red"} # => #<Document id=2444 color="red">
      def first_example(example)
        server_response = send_request "/simple/first-example",
          put: { "collection" => @name, "example" => example }
        Document.new @database, server_response
      end

      # Looks for documents in the collection based on location
      #
      # @option options [Integer] :latitude Latitude location for your search.
      # @option options [Integer] :longitude Longitude location for your search.
      # @option options [Integer] :skip The documents to skip in the query.
      # @option options [Integer] :distance If given, the attribute key used to store the distance.
      # @option options [Integer] :limit The maximal amount of documents to return (default: 100).
      # @option options [Integer] :geo If given, the identifier of the geo-index to use.
      # @return [Cursor]
      # @api public
      # @example Find all documents at Infinite Loop
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.near latitude: 37.331693, longitude: -122.030468
      def near(options={})
        send_simple_query "/simple/near", options, [:latitude, :longitude, :distance, :skip, :limit, :geo]
      end

      # Looks for documents in the collection within a certain radius
      #
      # @option options [Integer] :latitude Latitude location for your search.
      # @option options [Integer] :longitude Longitude location for your search.
      # @option options [Integer] :radius Radius around the given location you want to search in.
      # @option options [Integer] :skip The documents to skip in the query.
      # @option options [Integer] :distance If given, the attribute key used to store the distance.
      # @option options [Integer] :limit The maximal amount of documents to return (default: 100).
      # @option options [Integer] :geo If given, the identifier of the geo-index to use.
      # @return [Cursor]
      # @api public
      # @example Find all documents within a radius of 100 to Infinite Loop
      #   database = Ashikawa::Core::Database.new "http://localhost:8529"
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new database, raw_collection
      #   collection.within latitude: 37.331693, longitude: -122.030468, radius: 100
      def within(options={})
        send_simple_query "/simple/within", options, [:latitude, :longitude, :radius, :distance, :skip, :limit, :geo]
      end


      # Looks for documents in the collection with an attribute between two values
      #
      # @option options [Integer] :attribute The attribute path to check.
      # @option options [Integer] :left The lower bound
      # @option options [Integer] :right The upper bound
      # @option options [Integer] :closed If true, use intervall including left and right, otherwise exclude right, but include left.
      # @option options [Integer] :skip The documents to skip in the query (optional).
      # @option options [Integer] :limit The maximal amount of documents to return (optional).
      # @return [Cursor]
      # @api public
      def in_range(options={})
        send_simple_query "/simple/range", options, [:attribute, :left, :right, :closed, :limit, :skip]
      end

      # Fetch a certain document by its ID
      #
      # @param [Integer] document_id the id of the document
      # @raise [DocumentNotFoundException] If the requested document was not found
      # @return Document
      # @api public
      # @example Fetch a document with the ID 12345
      #   document = collection[12345]
      def [](document_id)
        begin
          server_response = send_request "/document/#{@id}/#{document_id}"
        rescue RestClient::ResourceNotFound
          raise DocumentNotFoundException
        end

        Document.new @database, server_response
      end

      # Replace a certain document by its ID
      #
      # @param [Integer] document_id the id of the document
      # @param [Hash] raw_document the data you want to replace it with
      # @api public
      def []=(document_id, raw_document)
        send_request "/document/#{@id}/#{document_id}", put: raw_document
      end

      # Create a document with given raw data
      #
      # @param [Hash] raw_document
      # @return DocumentHash
      # @api public
      def create(raw_document)
        server_response = send_request "/document?collection=#{@id}",
          post: raw_document

        Document.new @database, server_response
      end

      alias :<< :create

      # Add an index to the collection
      #
      # @param [Symbol] type What kind of index?
      # @option opts [Array<Symbol>] on On which fields?
      # @return Index
      # @api public
      def add_index(type, opts)
        server_response = send_request "/index?collection=#{@id}", post: {
          "type" => type.to_s,
          "fields" => opts[:on].map { |field| field.to_s }
        }

        Index.new self, server_response
      end

      # Get an index by ID
      #
      # @param [Int] id
      # @return Index
      # @api public
      def index(id)
        server_response = send_request "/index/#{@id}/#{id}"

        Index.new self, server_response
      end

      # Get all indices
      #
      # @return [Array<Index>]
      # @api public
      def indices
        server_response = send_request "/index?collection=#{@id}"

        server_response["indexes"].map do |raw_index|
          Index.new self, raw_index
        end
      end

      private

      # Send a request to the server with the name of the collection prepended
      #
      # @return [String] Response from the server
      # @api private
      def send_request_for_this_collection(path, method={})
        send_request "/collection/#{id}#{path}", method
      end

      # Send a simple query to the server
      #
      # @param [String] path The path for the request
      # @param [Hash] options The options given to the method
      # @param [Array<Symbol>] keys The required keys
      # @return [Hash] The parsed hash for the request
      # @api private
      def send_simple_query(path, options, keys)
        request_data = { "collection" => @name }

        keys.each do |key|
          request_data[key.to_s] = options[key] if options.has_key? key
        end

        server_response = send_request path, :put => request_data
        Cursor.new @database, server_response
      end
    end
  end
end
