require "ashikawa-core/exceptions/client_error/resource_not_found"

module Ashikawa
  module Core
    # This Exception is thrown when an index was requested from
    # the server that does not exist.
    class IndexNotFoundException < ResourceNotFound
      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "You requested an index from the server that does not exist"
      end
    end
  end
end
