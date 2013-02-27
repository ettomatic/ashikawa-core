module Ashikawa
  module Core
    # The client had an error in the request
    class ClientError < RuntimeError
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
        "Status #{@status}: An Error occured in the client"
      end
    end
  end
end
