module Ashikawa
  module Core
    # The server had an error during the request
    class ServerError < RuntimeError
      # Create a new instance
      #
      # @param [Integer] status
      # @return RuntimeError
      # @api private
      def initialize(status)
        @status = status
      end

      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "Status #{@status}: An Error occured on the server"
      end
    end
  end
end
