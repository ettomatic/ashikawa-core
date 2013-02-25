require 'ashikawa-core/document'

module Ashikawa
  module Core
    # A Cursor on a certain Database.
    # It is an enumerable.
    class Cursor
      include Enumerable

      # The ID of the cursor
      # @return [String]
      # @api public
      # @example Get the id of the cursor
      #   cursor = Ashikawa::Core::Cursor.new(database, raw_cursor)
      #   cursor.id #=> "1337"
      attr_reader :id

      # The number of documents
      # @return [Int]
      # @api public
      # @example Get the number of documents
      #   cursor = Ashikawa::Core::Cursor.new(database, raw_cursor)
      #   cursor.length #=> 23
      attr_reader :length

      # Initialize a Cursor with the database and raw data
      #
      # @param [Database] database
      # @param [Hash] raw_cursor
      # @api public
      # @example Create a new Cursor from the raw representation
      #   cursor = Ashikawa::Core::Cursor.new(database, raw_cursor)
      def initialize(database, raw_cursor)
        @database = database
        parse_raw_cursor(raw_cursor)
      end

      # Iterate over the documents found by the cursor
      #
      # @yield [document]
      # @return nil
      # @api public
      # @example Print all documents
      #   cursor = Ashikawa::Core::Cursor.new(database, raw_cursor)
      #   cursor.each do |document|
      #     p document
      #   end
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
      # @example Delete the cursor
      #   cursor = Ashikawa::Core::Cursor.new(database, raw_cursor)
      #   cursor.delete
      def delete
        @database.send_request("cursor/#{@id}", :delete => {})
      end

      private

      # Pull the raw data from the cursor into this object
      #
      # @return self
      # @api private
      def parse_raw_cursor(raw_cursor)
        @id       = raw_cursor['id']
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
        raw_cursor = @database.send_request("cursor/#{@id}", :put => {})
        parse_raw_cursor(raw_cursor)
      end
    end
  end
end
