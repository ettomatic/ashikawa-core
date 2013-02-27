require "faraday"
require "multi_json"
require "ashikawa-core/exceptions/index_not_found"
require "ashikawa-core/exceptions/document_not_found"
require "ashikawa-core/exceptions/collection_not_found"
require "ashikawa-core/exceptions/unknown_path"
require "ashikawa-core/exceptions/bad_request"

module Ashikawa
  module Core
    # Preprocessor for Faraday Requests
    class ResponsePreprocessor < Faraday::Middleware
      ClientErrorStatuses = 400...600

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
          else Ashikawa::Core::UnknownPath
        end
      end

      # Parse the JSON
      #
      # @param [Hash] env Environment info
      # @return [Hash] The parsed body
      # @api private
      def parse_json(env)
        MultiJson.load(env[:body])
      end

      # Handle the status code
      #
      # @param [Hash] env Environment info
      # @return [nil]
      # @api private
      def handle_status(env)
        status = env[:status]
        case status
        when 400 then raise Ashikawa::Core::BadRequest
        when 404 then raise resource_not_found_for(env)
        when ClientErrorStatuses then raise Faraday::Error::ClientError, status
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
