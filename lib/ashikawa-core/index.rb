module Ashikawa
  module Core
    # An index on a certain collection
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
      # @param [Hash] raw_index The JSON representation of the index
      # @return [Index]
      # @api public
      def initialize(collection, raw_index)
        @collection = collection
        @id = raw_index["id"].split("/")[1].to_i if raw_index.has_key?("id")
        @on = raw_index["fields"].map { |field| field.to_sym } if raw_index.has_key?("fields")
        @type = raw_index["type"].to_sym if raw_index.has_key?("type")
        @unique = raw_index["unique"] if raw_index.has_key?("unique")
      end

      # Remove the index from the collection
      #
      # @return [Hash] parsed JSON response from the server
      # @api public
      def delete
        @collection.send_request("index/#{@collection.id}/#{@id}", :delete => {})
      end
    end
  end
end
