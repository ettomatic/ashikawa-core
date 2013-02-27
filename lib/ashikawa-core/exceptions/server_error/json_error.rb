require "ashikawa-core/exceptions/server_error"

module Ashikawa
  module Core
    # This Exception is thrown when the Json
    # from the server was malformed
    class JsonError < ServerError
      # Create a new instance
      #
      # @return RuntimeError
      # @api private
      def initialize
        super(nil)
      end

      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "Either the JSON from the server was malformed or the content type incorrect"
      end
    end
  end
end
