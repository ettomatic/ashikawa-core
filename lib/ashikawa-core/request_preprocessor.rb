module Ashikawa
  module Core
    class RequestPreprocessor < Faraday::Middleware
      def initialize(app, logger)
        @app = app
        @logger = logger
      end

      def call(env)
        @logger.info("#{env[:method].upcase} #{env[:url]} #{env[:body]}")
        @app.call env
      end
    end

    Faraday.register_middleware :request,
      :ashikawa => lambda { RequestPreprocessor}
  end
end
