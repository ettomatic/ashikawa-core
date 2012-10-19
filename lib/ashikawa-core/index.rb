module Ashikawa
  module Core
    # Represents an index on a certain collection
    class Index
      # The fields the index is defined on as symbols
      # @return [Array<Symbol>]
      # @api public
      attr_reader :on

      # The type of index as a symbol
      # @return [Symbol]
      # @api public
      attr_reader :type

      # Is the unique constraint set?
      # @return [Boolean]
      # @api public
      attr_reader :unique

      # The id of the index
      # @return [Int]
      # @api public
      attr_reader :id

      # Create a new Index
      #
      # @param [Collection] collection The collection the index is defined on
      # @param [Hash] raw_cursor The JSON representation of the index
      # @return [Index]
      # @api
      def initialize(collection, raw_cursor)
        @collection = collection
        @id = raw_cursor["id"].split("/")[1].to_i if raw_cursor.has_key? "id"
        @on = raw_cursor["fields"].map { |field| field.to_sym } if raw_cursor.has_key? "fields"
        @type = raw_cursor["type"].to_sym if raw_cursor.has_key? "type"
        @unique = raw_cursor["unique"] if raw_cursor.has_key? "unique"
      end

      # Remove the index from the collection
      #
      # @api public
      def delete
        @collection.send_request("index/#{@collection.id}/#{@id}", delete: {})
      end
    end
  end
end
