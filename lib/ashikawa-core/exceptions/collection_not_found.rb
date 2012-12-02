module Ashikawa
  module Core
    # This Exception is thrown when a document was requested from
    # the server that does not exist.
    class CollectionNotFoundException < RuntimeError
      def to_s
        "You requested a collection from the server that does not exist"
      end
    end
  end
end
