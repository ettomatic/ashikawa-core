
module Ashikawa
  module Core
    class Document
      # The ID of the document
      # 
      # @return [String]
      # @api public
      attr_reader :id
      
      # The current revision of the document
      # 
      # @return [String]
      # @api public
      attr_reader :revision
      
      # Initialize a Document with an ID and revision
      # 
      # @param [String] id
      # @param [String] revision
      # @api public
      def initialize(id, revision)
        @id = id
        @revision = revision
      end
      
    end
  end
end