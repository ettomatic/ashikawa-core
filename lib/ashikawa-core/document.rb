module Ashikawa
  module Core
    # Represents a certain Document within a certain Collection
    class Document
      # The ID of the document including the Collection prefix
      # 
      # @return [String]
      # @api public
      # @example Get the ID for a Document
      #   document = Ashikawa::Core::Document.new "1234567/2345678", "3456789"
      #   document.id # => "1234567/2345678"
      attr_reader :id
      
      # The current revision of the document
      # 
      # @return [String]
      # @api public
      # @example Get the Revision for a Document
      #   document = Ashikawa::Core::Document.new "1234567/2345678", "3456789"
      #   document.revision # => "3456789"
      attr_reader :revision
      
      # Initialize a Document with an ID and revision
      # 
      # @param [String] id The complete ID including the Collection prefix
      # @param [String] revision
      # @api public
      # @example The Document 2345678 in the Collection 1234567 in revision 3456789
      #   document = Ashikawa::Core::Document.new "1234567/2345678", "3456789"
      def initialize(id, revision)
        @id = id
        @revision = revision
      end
      
    end
  end
end