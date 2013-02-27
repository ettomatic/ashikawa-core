require "faraday"

module Ashikawa
  module Core
    # Preprocessor for Faraday Requests
    class ResponsePreprocessor < Faraday::Middleware
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
          body = env[:body]
          log(env[:status], body)
          env[:body] = JSON.parse(body)
        end
      end

      private

      # Log a Request
      #
      # @param [String] status
      # @param [String] body
      # @return [nil]
      # @api private
      def log(status, body)
        @logger.info("#{status} #{body}")
        nil
      end
    end

    Faraday.register_middleware :response,
      :ashikawa_response => lambda { ResponsePreprocessor}
  end
end
