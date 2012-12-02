module Ashikawa
  module Core
    # This Exception is thrown when you request
    # a path from the server which is not known
    class UnknownPath < RuntimeError
      def to_s
        "The path is unknown"
      end
    end
  end
end
