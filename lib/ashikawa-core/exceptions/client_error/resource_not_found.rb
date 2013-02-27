require "ashikawa-core/exceptions/client_error.rb"

module Ashikawa
  module Core
    # This Exception is thrown when you request
    # a resource that does not exist on the server
    class ResourceNotFound < ClientError
      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        "The Resource you requested was not found on the server"
      end
    end
  end
end
