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
      # @param [Hash] raw_data The JSON representation of the index
      # @return [Index]
      # @api
      def initialize(collection, raw_data)
        @collection = collection
        @id = raw_data["id"].split("/")[1].to_i if raw_data["id"]
        @on = raw_data["fields"].map { |field| field.to_sym } if raw_data.has_key? "fields"
        @type = raw_data["type"].to_sym if raw_data.has_key? "type"
        @unique = raw_data["unique"] if raw_data.has_key? "unique"
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
