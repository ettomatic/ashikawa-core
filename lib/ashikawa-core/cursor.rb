require 'ashikawa-core/document'

module Ashikawa
  module Core
    # A Cursor on a certain Database.
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
        parse_raw_cursor(raw_cursor)
      end

      # Iterate over the documents found by the cursor
      #
      # @yield [document]
      # @return nil
      # @api public
      def each
        begin
          @current.each do |raw_document|
            yield Document.new(@database, raw_document)
          end
        end while next_batch
        nil
      end

      # Delete the cursor
      # @return [Hash] parsed JSON response from the server
      # @api public
      def delete
        @database.send_request("/cursor/#{@id}", :delete => {})
      end

      private

      # Pull the raw data from the cursor into this object
      #
      # @return self
      # @api private
      def parse_raw_cursor(raw_cursor)
        @id       = raw_cursor['id'].to_i if raw_cursor.has_key?('id')
        @has_more = raw_cursor['hasMore']
        @length   = raw_cursor['count'].to_i if raw_cursor.has_key?('count')
        @current  = raw_cursor['result']
        self
      end

      # Get a new batch from the server
      #
      # @return [Boolean] Is there a next batch?
      # @api private
      def next_batch
        return false unless @has_more
        raw_cursor = @database.send_request("/cursor/#{@id}", :put => {})
        parse_raw_cursor(raw_cursor)
      end
    end
  end
end
