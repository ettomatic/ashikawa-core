module Ashikawa
  module Core
    # The server had an error during the request
    class ServerError < RuntimeError
      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "An Error occured on the server"
      end
    end
  end
end
