require "ashikawa-core/document"

module Ashikawa
  module Core
    class Collection
      # The name of the collection, must be unique
      attr_reader :name
      
      # The ID of the collection. Is set by the database and unique
      attr_reader :id
      
      # Create a new Collection object with a name and an optional ID
      # 
      # @param [Database] database The database the connection belongs to
      # @param [Hash] raw_collection The raw collection returned from the server
      def initialize(database, raw_collection)
        @database = database
        @name = raw_collection['name'] if raw_collection.has_key? 'name'
        @id  = raw_collection['id'].to_i if raw_collection.has_key? 'id'
        @status = raw_collection['status'].to_i if raw_collection.has_key? 'status'
      end
      
      # Change the name of the collection
      def name=(new_name)
        send_request_for_this_collection "/rename", put: { "name" => new_name }
      end
      
      # Checks if the collection is new born (This is derived from the status code 1)
      def new_born?
        @status == 1
      end
      
      # Checks if the collection is unloaded (This is derived from the status code 2)
      def unloaded?
        @status == 2
      end
      
      # Checks if the collection is loaded (This is derived from the status code 3)
      def loaded?
        @status == 3
      end
      
      # Checks if the collection is in the process of being unloaded (This is derived from the status code 4)
      def being_unloaded?
        @status == 4
      end
      
      # Checks if the collection is deleted (This is derived from the status code 5)
      def deleted?
        @status == 5
      end
      
      # Checks if the collection is corrupted (This is the case, if the status code is greater than 5)
      def corrupted?
        @status > 5
      end
      
      # Checks if the collection waits for sync: If `true` then creating or changing a document will wait until the data has been synchronised to disk
      def wait_for_sync?
        server_response = send_request_for_this_collection "/parameter"
        server_response["waitForSync"]
      end
      
      # Change if the collection waits for sync: If `true` then creating or changing a document will wait until the data has been synchronised to disk
      def wait_for_sync=(new_value)
        server_response = send_request_for_this_collection "/parameter", put: { "waitForSync" => new_value }
      end
      
      # Returns the number of documents in the collection
      # 
      # @return [Fixnum] Number of documents
      def length
        server_response = send_request_for_this_collection "/count"
        server_response["count"]
      end
      
      # Return a figure for the collection. The figure can be one of:
      # 1. :datafiles_count The number of active datafiles
      # 2. :alive_size The total size in bytes used by all living documents
      # 3. :alive_count The number of living documents
      # 4. :dead_size The total size in bytes used by all dead documents
      # 5. :dead_count The number of dead documents
      # 
      # @param [Symbol] figure_type The figure you want to know
      # @return [Fixnum] The figure you requested
      def figure(figure_type)
        server_response = send_request_for_this_collection "/figures"
        
        figure_area, figure_name = figure_type.to_s.split "_"
        server_response["figures"][figure_area][figure_name]
      end
      
      # Deletes the collection
      def delete
        send_request_for_this_collection "", delete: {}
      end
      
      # Load the collection into memory
      def load
        send_request_for_this_collection "/load", put: {}
      end
      
      # Load the collection into memory
      def unload
        send_request_for_this_collection "/unload", put: {}
      end
      
      # Delete all documents from the collection
      def truncate
        send_request_for_this_collection "/truncate", put: {}
      end
      
      # Retrieves all documents for this collection
      # 
      # @note It is advised to NOT use this method due to possible HUGE data amounts requested
      # @param [Hash] options Additional options for this query.
      # @option options [Integer] :limit limit the maximum number of queried and returned elements.
      # @option options [Integer] :skip skip the first <n> documents of the query.
      # @return [Array<Document>]
      def all(options={})
        request_data = { "collection" => @name }
        
        request_data["limit"] = options[:limit] if options.has_key? :limit
        request_data["skip"] = options[:skip] if options.has_key? :skip
        
        server_response = @database.send_request "/simple/all", :put => request_data
        
        documents_from_response(server_response)
      end
      
      # Looks for documents in the collection which match the given criteria
      # 
      # @param [Hash] reference_data a Hash with data similar to the documents you are looking for.
      # @param [Hash] options Additional options for this query.
      # @option options [Integer] :limit limit the maximum number of queried and returned elements.
      # @option options [Integer] :skip skip the first <n> documents of the query.
      # @return [Array<Document>]
      def by_example(reference_data, options={})
        request_data = { "collection" => @name, "example" => reference_data }
        
        request_data["limit"] = options[:limit] if options.has_key? :limit
        request_data["skip"] = options[:skip] if options.has_key? :skip        
        
        server_response = @database.send_request "/simple/by-example", :put => request_data
        
        documents_from_response(server_response)
      end
      
      private
      
      def send_request_for_this_collection(path, method={})
        if method == {}
          @database.send_request "/collection/#{id}#{path}"
        else
          @database.send_request "/collection/#{id}#{path}", method
        end
      end
      
      # Takes JSON returned by the database and collects Documents from the data
      # 
      # @param [Array<Hash>] parsed_server_response parsed JSON response from the server. Should contain document-hashes.
      # @return [Array<Document>]
      def documents_from_response(parsed_server_response)
        parsed_server_response.collect do |document|
          Ashikawa::Core::Document.new(document["_id"], document["_rev"])
        end
      end
      
    end
  end
end