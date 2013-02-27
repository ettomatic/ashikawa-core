require "ashikawa-core/exceptions/client_error.rb"

module Ashikawa
  module Core
    # This Exception is thrown when you request
    # a resource that does not exist on the server
    class ResourceNotFound < ClientError
      # Create a new instance
      #
      # @return RuntimeError
      # @api private
      def initialize
        super(404)
      end

      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "Status 404: The Resource you requested was not found on the server"
      end
    end
  end
end
