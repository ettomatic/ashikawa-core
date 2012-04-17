
module Ashikawa
  module Core
    class Document
      # The ID of the document
      # 
      # @return [String]
      attr_reader :id
      
      # The current revision of the document
      # 
      # @return [String]
      attr_reader :revision
      
      def initialize(id, revision)
        @id = id
        @revision = revision
      end
      
    end
  end
end