module Ashikawa
  module Core
    # This Exception is thrown when a document was requested from
    # the server that does not exist.
    class DocumentNotFoundException < RuntimeError
      # String representation of the exception
      #
      # @return String
      # @api public
      def to_s
        "You requested a document from the server that does not exist"
      end
    end
  end
end
