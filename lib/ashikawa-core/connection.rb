require "rest-client"
require "json"
require "uri"
require "ashikawa-core/exceptions/index_not_found"
require "ashikawa-core/exceptions/document_not_found"
require "ashikawa-core/exceptions/collection_not_found"
require "ashikawa-core/exceptions/unknown_path"

module Ashikawa
  module Core
    # A Connection via HTTP to a certain host
    class Connection
      # The host part of the connection
      #
      # @return [String]
      # @api public
      # @example Get the host part of the connection
      #   connection = Connection.new "http://localhost:8529"
      #   connection.host # => "localhost"
      attr_reader :host

      # The scheme of the connection
      #
      # @return [String]
      # @api public
      # @example Get the scheme of the connection
      #   connection = Connection.new "http://localhost:8529"
      #   connection.scheme # => "http"
      attr_reader :scheme

      # The port of the connection
      #
      # @return [Fixnum]
      # @api public
      # @example Get the port of the connection
      #   connection = Connection.new "http://localhost:8529"
      #   connection.port # => 8529
      attr_reader :port

      # Username of the connection if using authentication
      # @note you can set these properties with the `authenticate_with` method
      #
      # @return String
      # @api public

      attr_reader :username

      # Password of the connection if using authentication
      # @note you can set these properties with the `authenticate_with` method
      #
      # @return String
      # @api public
      attr_reader :password

      # Initialize a Connection with a given API String
      #
      # @param [String] api_string scheme, hostname and port as a String
      # @api public
      # @example Create a new Connection
      #  connection = Connection.new "http://localhost:8529"
      def initialize(api_string = "http://localhost:8529")
        uri     = URI(api_string)
        @host   = uri.host
        @port   = uri.port
        @scheme = uri.scheme
      end

      # Sends a request to a given path returning the parsed result
      # @note prepends the api_string automatically
      #
      # @example get request
      #   connection.send_request('/collection/new_collection')
      # @example post request
      #   connection.send_request('/collection/new_collection', :post => { :name => 'new_collection' })
      # @param [String] path the path you wish to send a request to.
      # @option params [Hash] :post POST data in case you want to send a POST request.
      # @return [Hash] parsed JSON response from the server
      # @api public
      def send_request(path, params = {})
        begin
          raw = raw_result_for(path, params)
        rescue RestClient::ResourceNotFound
          resource_not_found_for(path)
        end
        JSON.parse(raw)
      end

      # Raise the fitting ResourceNotFoundException
      #
      # @raise [DocumentNotFoundException, CollectionNotFoundException, IndexNotFoundException]
      # @return nil
      # @api private
      def resource_not_found_for(path)
        path = path.split("/").delete_if { |e| e == "" }
        resource = path.first

        raise case resource
          when "document" then DocumentNotFoundException
          when "collection" then CollectionNotFoundException
          when "index" then IndexNotFoundException
          else UnknownPath
        end
      end

      # Sends a request to a given path returning the raw result
      # @note prepends the api_string automatically
      #
      # @example get request
      #   connection.raw_result_for('/collection/new_collection')
      # @example post request
      #   connection.raw_result_for('/collection/new_collection', :post => { :name => 'new_collection' })
      # @param [String] path the path you wish to send a request to.
      # @option params [Hash] :post POST data in case you want to send a POST request.
      # @return [String] raw response from the server
      # @api public
      def raw_result_for(path, params = {})
        path   = full_path(path)
        method = [:post, :put, :delete].find { |method_name|
          params.has_key?(method_name)
        } || :get

        if [:post, :put].include?(method)
          RestClient.send(method, path, params[method].to_json)
        else
          RestClient.send(method, path)
        end
      end

      # Checks if authentication for this Connection is active or not
      #
      # @return [Boolean]
      # @api public
      def authentication?
        !!@username
      end

      # Authenticate with given username and password
      #
      # @option [String] username
      # @option [String] password
      # @return [self]
      # @raise [ArgumentError] if username or password are missing
      # @api public
      def authenticate_with(options = {})
        if options.key? :username and options.key? :password
          @username = options[:username]
          @password = options[:password]
        else
          raise ArgumentError, 'missing username or password'
        end

        self
      end

      # Return the full path for a given API path
      #
      # @param [String] path The API path
      # @return [String] Full path
      # @api public
      def full_path(path)
        prefix = if authentication?
          "#{@scheme}://#{@username}:#{@password}@#{@host}:#{@port}"
        else
          "#{@scheme}://#{@host}:#{@port}"
        end

        "#{prefix}/_api/#{path.gsub(/^\//, '')}"
      end
    end
  end
end
