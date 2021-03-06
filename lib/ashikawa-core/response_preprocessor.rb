require "faraday"
require "multi_json"
require "ashikawa-core/exceptions/client_error"
require "ashikawa-core/exceptions/client_error/resource_not_found"
require "ashikawa-core/exceptions/client_error/resource_not_found/index_not_found"
require "ashikawa-core/exceptions/client_error/resource_not_found/document_not_found"
require "ashikawa-core/exceptions/client_error/resource_not_found/collection_not_found"
require "ashikawa-core/exceptions/client_error/bad_syntax"
require "ashikawa-core/exceptions/server_error"
require "ashikawa-core/exceptions/server_error/json_error"

module Ashikawa
  module Core
    # Preprocessor for Faraday Requests
    class ResponsePreprocessor < Faraday::Middleware
      ClientErrorStatuses = 400...499
      ServerErrorStatuses = 500...599
      BadSyntaxStatus = 400
      ResourceNotFoundErrorError = 404

      # Create a new Response Preprocessor
      #
      # @param [Object] app Faraday internal
      # @param [Object] logger The object you want to log to
      # @return [ResponsePreprocessor]
      # @api private
      def initialize(app, logger)
        @app = app
        @logger = logger
      end

      # Process a Response
      #
      # @param [Hash] env Environment info
      # @return [Object]
      # @api private
      def call(env)
        @app.call(env).on_complete do
          log(env)
          handle_status(env)
          env[:body] = parse_json(env)
        end
      end

      private

      # Raise the fitting ResourceNotFoundException
      #
      # @raise [DocumentNotFoundException, CollectionNotFoundException, IndexNotFoundException]
      # @return nil
      # @api private
      def resource_not_found_for(env)
        raise case env[:url].path
          when /\A\/_api\/document/ then Ashikawa::Core::DocumentNotFoundException
          when /\A\/_api\/collection/ then Ashikawa::Core::CollectionNotFoundException
          when /\A\/_api\/index/ then Ashikawa::Core::IndexNotFoundException
          else Ashikawa::Core::ResourceNotFound
        end
      end

      # Parse the JSON
      #
      # @param [Hash] env Environment info
      # @return [Hash] The parsed body
      # @api private
      def parse_json(env)
        raise MultiJson::LoadError unless json_content_type?(env[:response_headers]["content-type"])
        MultiJson.load(env[:body])
      rescue MultiJson::LoadError
        raise Ashikawa::Core::JsonError
      end

      # Check if the Content Type is JSON
      #
      # @param [String] content_type
      # @return [Boolean]
      # @api private
      def json_content_type?(content_type)
        content_type == "application/json; charset=utf-8"
      end

      # Handle the status code
      #
      # @param [Hash] env Environment info
      # @return [nil]
      # @api private
      def handle_status(env)
        status = env[:status]
        case status
        when BadSyntaxStatus then raise Ashikawa::Core::BadSyntax
        when ResourceNotFoundErrorError then raise resource_not_found_for(env)
        when ClientErrorStatuses then raise Ashikawa::Core::ClientError, status
        when ServerErrorStatuses then raise Ashikawa::Core::ServerError, status
        end
      end

      # Log a Request
      #
      # @param [Hash] env Environment info
      # @return [nil]
      # @api private
      def log(env)
        @logger.info("#{env[:status]} #{env[:body]}")
        nil
      end
    end

    Faraday.register_middleware :response,
      :ashikawa_response => lambda { ResponsePreprocessor}
  end
end
