module Ashikawa
  module Core
    # This Exception is thrown when you request something that does not exist
    class BadRequest < RuntimeError
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
