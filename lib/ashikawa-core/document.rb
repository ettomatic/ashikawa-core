module Ashikawa
  module Core
    # Represents a certain Document within a certain Collection
    class Document
      # The ID of the document without the Collection prefix
      #
      # @return [Int]
      # @api public
      # @example Get the ID for a Document
      #   document = Ashikawa::Core::Document.new collection, raw_document
      #   document.id # => 2345678
      attr_reader :id

      # The current revision of the document
      #
      # @return [Int]
      # @api public
      # @example Get the Revision for a Document
      #   document = Ashikawa::Core::Document.new collection, raw_document
      #   document.revision # => 3456789
      attr_reader :revision

      # Initialize a Document with an ID and revision
      #
      # @param [Collection] collection
      # @param [Hash] raw_document
      # @api public
      # @example The Document 2345678 in the Collection 1234567 in revision 3456789
      #   document = Ashikawa::Core::Document.new collection, raw_document
      def initialize(collection, raw_document)
        @collection = collection
        @id = raw_document['_id'].split('/')[1].to_i if raw_document.has_key? '_id'
        @revision = raw_document['_rev'].to_i if raw_document.has_key? '_rev'
        @content = raw_document.delete_if { |key, value| key[0] == "_" }
      end

      # Get the value of an attribute of the document
      #
      # @param [String] attribute_name
      # @api public
      # @return [Object] The value of the attribute
      def [](attribute_name)
        @content[attribute_name]
      end

      # Remove the document from the database
      #
      # @api public
      def delete
        @collection.send_request "document/#{@collection.id}/#{@id}", delete: {}
      end

      # Update the value of an attribute (Does not write to database)
      #
      # @param [String] attribute_name
      # @param [Object] value
      # @api public
      def []=(attribute_name, value)
        @content[attribute_name] = value
      end

      # Save the changes to the database
      #
      # @api public
      def save()
        @collection.send_request "document/#{@collection.id}/#{@id}", put: @content
      end
    end
  end
end
