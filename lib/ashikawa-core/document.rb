require 'ashikawa-core/exceptions/document_not_found'

module Ashikawa
  module Core
    # Represents a certain Document within a certain Collection
    class Document
      # The ID of the document without the Collection prefix
      #
      # @return [Int]
      # @api public
      # @example Get the ID for a Document
      #   document = Ashikawa::Core::Document.new database, raw_document
      #   document.id # => 2345678
      attr_reader :id

      # The current revision of the document
      #
      # @return [Int]
      # @api public
      # @example Get the Revision for a Document
      #   document = Ashikawa::Core::Document.new database, raw_document
      #   document.revision # => 3456789
      attr_reader :revision

      # Initialize a Document with the database and raw data
      #
      # @param [Database] database
      # @param [Hash] raw_document
      # @api public
      def initialize(database, raw_document)
        @database = database
        @is_persistent = raw_document.has_key?('_id') and raw_document.has_key?('rev')

        if @is_persistent
          @collection_id, @id = raw_document['_id'].split('/').map { |id| id.to_i }
          @revision = raw_document['_rev'].to_i
        end

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
        raise DocumentNotFoundException unless @is_persistent
        @database.send_request "document/#{@collection_id}/#{@id}", delete: {}
      end

      # Update the value of an attribute (Does not write to database)
      #
      # @param [String] attribute_name
      # @param [Object] value
      # @api public
      def []=(attribute_name, value)
        raise DocumentNotFoundException unless @is_persistent
        @content[attribute_name] = value
      end

      # Convert the document into a hash
      #
      # @return [Hash]
      # @api public
      def to_hash
        @content
      end

      # Save the changes to the database
      #
      # @api public
      def save()
        raise DocumentNotFoundException unless @is_persistent
        @database.send_request "document/#{@collection_id}/#{@id}", put: @content
      end
    end
  end
end
