module Ashikawa
  module Core
    # The client had an error in the request
    class ClientError < RuntimeError
      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "An Error occured in the client"
      end
    end
  end
end
