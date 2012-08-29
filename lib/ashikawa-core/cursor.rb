require 'ashikawa-core/document'

module Ashikawa
  module Core
    # Represents a Cursor on a certain Database.
    # It is an enumerable.
    class Cursor
      include Enumerable

      # The ID of the cursor
      # @return [Int]
      # @api public
      attr_reader :id

      # The number of documents
      # @return [Int]
      # @api public
      attr_reader :length

      # Initialize a Cursor with the database and raw data
      #
      # @param [Database] database
      # @param [Hash] raw_cursor
      # @api public
      def initialize(database, raw_cursor)
        @database = database
        @id       = raw_cursor['id'].to_i if raw_cursor.has_key? 'id'
        @has_more = raw_cursor['hasMore']
        @length   = raw_cursor['count'].to_i if raw_cursor.has_key? 'count'
        @current  = raw_cursor['result']
      end

      # Iterate over the documents found by the cursor
      #
      # @yield [document]
      # @api public
      def each(&block)
        begin
          @current.each do |raw_document|
            block.call Document.new(nil, raw_document)
          end
        end while next_batch
      end

      # Delete the cursor
      def delete
        @database.send_request "/cursor/#{@id}", delete: {}
      end

      private

      # Get a new batch from the server
      #
      # @return [Boolean] Is there a next batch?
      def next_batch
        return @false unless @has_more
        raw_cursor = @database.send_request "/cursor/#{@id}", put: {}
        @id       = raw_cursor['id']
        @has_more = raw_cursor['hasMore']
        @length   = raw_cursor['count']
        @current  = raw_cursor['result']
      end
    end
  end
end
