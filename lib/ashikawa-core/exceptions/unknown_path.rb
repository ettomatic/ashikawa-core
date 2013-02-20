module Ashikawa
  module Core
    # This Exception is thrown when you request
    # a path from the server which is not known
    class UnknownPath < RuntimeError
      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "The path is unknown"
      end
    end
  end
end
