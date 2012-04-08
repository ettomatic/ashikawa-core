module Ashikawa
  module Core
    class Collection
      # The name of the collection, must be unique.
      attr_reader :name
      
      # The ID of the collection. Is set by the database and unique.
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
      
      # Checks if the collection is new born. This is derived from the status code 1.
      def new_born?
        @status == 1
      end
      
      # Checks if the collection is unloaded. This is derived from the status code 2.
      def unloaded?
        @status == 2
      end
      
      # Checks if the collection is loaded. This is derived from the status code 3.
      def loaded?
        @status == 3
      end
      
      # Checks if the collection is in the process of being unloaded. This is derived from the status code 4.
      def being_unloaded?
        @status == 4
      end
      
      # Checks if the collection is deleted. This is derived from the status code 5.
      def deleted?
        @status == 5
      end
      
      # Checks if the collection is corrupted. This is the case, if the status code is greater than 5.
      def corrupted?
        @status > 5
      end
      
      # Checks if the collection waits for sync: If `true` then creating or changing a document will wait until the data has been synchronised to disk.
      def wait_for_sync?
        server_response = @database.send_request "/collection/#{id}/parameter"
        server_response["waitForSync"]
      end
      
      # Returns the number of documents in the collection.
      # 
      # @return [Fixnum] Number of documents
      def length
        server_response = @database.send_request "/collection/#{id}/count"
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
        server_response = @database.send_request "/collection/#{id}/figures"
        case figure_type
        when :datafiles_count
          server_response["figures"]["datafiles"]["count"]
        when :alive_size
          server_response["figures"]["alive"]["size"]
        when :alive_count
          server_response["figures"]["alive"]["count"]
        when :dead_size
          server_response["figures"]["dead"]["size"]
        when :dead_count
          server_response["figures"]["dead"]["count"]
        end
      end
      
      # Deletes the collection
      def delete
        @database.send_request "/collection/#{id}", delete: {}
      end
      
      # Load the collection into memory
      def load
        @database.send_request "/collection/#{id}/load", put: {}
      end
      
      # Load the collection into memory
      def unload
        @database.send_request "/collection/#{id}/unload", put: {}
      end
      
      # Delete all documents from the collection
      def truncate
        @database.send_request "/collection/#{id}/truncate", put: {}
      end
      
    end
  end
end