module Ashikawa
  module Core
    # This Exception is thrown, when a document was requested from
    # the server that does not exist.
    class DocumentNotFoundException < RuntimeError
    end
  end
end
