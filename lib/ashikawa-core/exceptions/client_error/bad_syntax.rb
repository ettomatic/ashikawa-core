require "ashikawa-core/exceptions/client_error.rb"

module Ashikawa
  module Core
    # This exception is thrown when the client used bad syntax in a request
    class BadSyntax < ClientError
      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "The syntax of the request was bad"
      end
    end
  end
end
