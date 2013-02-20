require "ashikawa-core/document"
require "ashikawa-core/index"
require "ashikawa-core/cursor"
require "ashikawa-core/query"
require "ashikawa-core/status"
require "ashikawa-core/figure"
require "forwardable"

module Ashikawa
  module Core
    # A certain Collection within the Database
    class Collection
      extend Forwardable

      # The name of the collection, must be unique
      #
      # @return [String]
      # @api public
      # @example Change the name of a collection
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.name # => "example_1"
      #   collection.name = "example_2"
      #   collection.name # => "example_2"
      attr_reader :name

      # The ID of the collection. Is set by the database and unique
      #
      # @return [Fixnum]
      # @api public
      # @example Get the id of the collection
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.id #=> 4588
      attr_reader :id

      # A wrapper around the status of the collection
      #
      # @return [Status]
      # @api public
      # @example
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.status.loaded? #=> true
      #   collection.status.new_born? #=> false
      attr_reader :status

      # The database the collection belongs to
      #
      # @return [Database]
      # @api public
      # @example
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.database #=> #<Database: ...>
      attr_reader :database

      # Sending requests is delegated to the database
      def_delegator :@database, :send_request

      # Create a new Collection object with a name and an optional ID
      #
      # @param [Database] database The database the connection belongs to
      # @param [Hash] raw_collection The raw collection returned from the server
      # @api public
      # @example Create a Collection object from scratch
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      def initialize(database, raw_collection)
        @database = database
        @name     = raw_collection['name']                   if raw_collection.has_key?('name')
        @id       = raw_collection['id'].to_i                if raw_collection.has_key?('id')
        @status   = Status.new raw_collection['status'].to_i if raw_collection.has_key?('status')
      end

      # Change the name of the collection
      #
      # @param [String] new_name New Name
      # @return [String] New Name
      # @api public
      # @example Change the name of a collection
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.name # => "example_1"
      #   collection.name = "example_2"
      #   collection.name # => "example_2"
      def name=(new_name)
        send_information_to_server(:rename, :name, new_name)
        @name = new_name
      end

      # Does the document wait until the data has been synchronised to disk?
      #
      # @return [Boolean]
      # @api public
      # @example Does the collection wait for file synchronization?
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.wait_for_sync? #=> false
      def wait_for_sync?
        get_information_from_server(:properties, :waitForSync)
      end

      # Change if the document will wait until the data has been synchronised to disk
      #
      # @return [String] Response from the server
      # @api public
      # @example Tell the collection to wait for file synchronization
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.wait_for_sync = true
      def wait_for_sync=(new_value)
        send_information_to_server(:properties, :waitForSync, new_value)
      end

      # Returns the number of documents in the collection
      #
      # @return [Fixnum] Number of documents
      # @api public
      # @example How many documents are in the collection?
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.length # => 0
      def length
        get_information_from_server(:count, :count)
      end

      # Return a Figure initialized with current data for the collection
      #
      # @return [Figure]
      # @api public
      # @example Get the datafile count for a collection
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.figure.datafiles_count #=> 0
      def figure
        raw_figure = get_information_from_server(:figures, :figures)
        Figure.new(raw_figure)
      end

      # Deletes the collection
      #
      # @return [String] Response from the server
      # @api public
      # @example Delete a collection
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.delete
      def delete
        send_request_for_this_collection("", :delete => {})
      end

      # Load the collection into memory
      #
      # @return [String] Response from the server
      # @api public
      # @example Load a collection into memory
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.load
      def load
        send_command_to_server(:load)
      end

      # Load the collection into memory
      #
      # @return [String] Response from the server
      # @api public
      # @example Unload a collection into memory
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.unload
      def unload
        send_command_to_server(:unload)
      end

      # Delete all documents from the collection
      #
      # @return [String] Response from the server
      # @api public
      # @example Remove all documents from a collection
      #   database = Ashikawa::Core::Database.new("http://localhost:8529")
      #   raw_collection = {
      #     "name" => "example_1",
      #     "waitForSync" => true,
      #     "id" => 4588,
      #     "status" => 3,
      #     "error" => false,
      #     "code" => 200
      #   }
      #   collection = Ashikawa::Core::Collection.new(database, raw_collection)
      #   collection.truncate!
      def truncate!
        send_command_to_server(:truncate)
      end

      # Fetch a certain document by its ID
      #
      # @param [Integer] document_id the id of the document
      # @raise [DocumentNotFoundException] If the requested document was not found
      # @return Document
      # @api public
      # @example Fetch the document with the ID 12345
      #   document = collection[12345]
      def [](document_id)
        server_response = send_request("/document/#{@id}/#{document_id}")
        Document.new(@database, server_response)
      end

      # Replace a document by its ID
      #
      # @param [Integer] document_id the id of the document
      # @param [Hash] raw_document the data you want to replace it with
      # @return [Hash] parsed JSON response from the server
      # @api public
      # @example Replace the document with the ID 12345
      #   collection[12345] = document
      def []=(document_id, raw_document)
        send_request("/document/#{@id}/#{document_id}", :put => raw_document)
      end

      # Create a new document from raw data
      #
      # @param [Hash] raw_document
      # @return [Document] The created document
      # @api public
      # @example Create a new document from raw data
      #   collection.create(raw_document)
      def create(raw_document)
        server_response = send_request("/document?collection=#{@id}", :post => raw_document)
        Document.new(@database, server_response)
      end

      alias :<< :create

      # Add an index to the collection
      #
      # @param [Symbol] type specify the type of the index, for example `:hash`
      # @option opts [Array<Symbol>] on fields on which to apply the index
      # @return Index
      # @api public
      # @example Add a hash-index to the fields :name and :profession of a collection
      #   people = database['people']
      #   people.add_index(:hash, :on => [:name, :profession])
      def add_index(type, opts)
        response = send_request("/index?collection=#{@id}", :post => {
          "type" => type.to_s,
          "fields" => opts[:on].map { |field| field.to_s }
        })

        Index.new(self, response)
      end

      # Get an index by ID
      #
      # @param [Integer] id
      # @return Index
      # @api public
      # @example Get an Index by its ID
      #   people = database['people']
      #   people.index(1244) #=> #<Index: id=1244...>
      def index(id)
        server_response = send_request("/index/#{@id}/#{id}")
        Index.new(self, server_response)
      end

      # Get all indices
      #
      # @return [Array<Index>]
      # @api public
      # @example Get all indices
      #   people = database['people']
      #   people.indices #=> [#<Index: id=1244...>, ...]
      def indices
        server_response = send_request("/index?collection=#{@id}")

        server_response["indexes"].map do |raw_index|
          Index.new(self, raw_index)
        end
      end

      # Return a Query initialized with this collection
      #
      # @return [Query]
      # @api public
      # @example Get all documents in this collection
      #   people = database['people']
      #   people.query.all #=> #<Cursor: id=1244...>
      def query
        Query.new(self)
      end

      private

      # Send a put request with a given key and value to the server
      #
      # @param [Symbol] path
      # @param [Symbol] key
      # @param [Symbol] value
      # @return [Object] The result
      # @api private
      def send_information_to_server(path, key, value)
        send_request_for_this_collection("/#{path}", :put => { key.to_s => value })
      end

      # Send a put request with the given command
      #
      # @param [Symbol] command The command you want to execute
      # @return [Object] The result
      # @api private
      def send_command_to_server(command)
        send_request_for_this_collection("/#{command}", :put => {})
      end

      # Send a get request to the server and return a certain attribute
      #
      # @param [Symbol] path The path without trailing slash
      # @param [Symbol] attribute The attribute of the answer that should be returned
      # @return [Object] The result
      # @api private
      def get_information_from_server(path, attribute)
        server_response = send_request_for_this_collection("/#{path}")
        server_response[attribute.to_s]
      end

      # Send a request to the server with the name of the collection prepended
      #
      # @return [String] Response from the server
      # @api private
      def send_request_for_this_collection(path, method={})
        send_request("/collection/#{id}#{path}", method)
      end
    end
  end
end
