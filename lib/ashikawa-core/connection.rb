require "rest-client"
require "json"

module Ashikawa
  module Core
    # Represents a Connection via HTTP to a certain host
    class Connection
      # The IP of the connection
      # 
      # @return [String]
      # @api public
      # @example Get the IP of the connection
      #   connection = Connection.new "http://localhost:8529"
      #   connection.ip # => "http://localhost"
      attr_reader :ip
      
      # The port of the connection
      # 
      # @return [Fixnum]
      # @api public
      # @example Get the port of the connection
      #   connection = Connection.new "http://localhost:8529"
      #   connection.port # => 8529
      attr_reader :port
      
      # Initialize a Connection with a given API String
      # 
      # @param [String] api_string IP and Port as a String
      # @api public
      # @example Create a new Connection
      #  connection = Connection.new "http://localhost:8529"
      def initialize(api_string)
        @api_string = api_string
        @ip, @port = @api_string.scan(/(\S+):(\d+)/).first
        @port = @port.to_i
      end
      
      # Sends a request to a given path (Prepends the api_string automatically)
      # 
      # @example get request 
      #   connection.send_request('/collection/new_collection')
      # @example post request
      #   connection.send_request('/collection/new_collection', :post => { :name => 'new_collection' })
      # @param [String] path the path you wish to send a request to.
      # @param [Hash] method_params additional parameters for your request. Only needed if you want to send something other than a GET request.
      # @option method_params [Hash] :post POST data in case you want to send a POST request.
      # @return [Hash] parsed JSON response from the server
      # @api semipublic
      def send_request(path, method_params = {})
        path.gsub! /^\//, ''
        
        if method_params.has_key? :post
          JSON.parse RestClient.post("#{@api_string}/_api/#{path}", method_params[:post].to_json )
        elsif method_params.has_key? :put
          JSON.parse RestClient.put("#{@api_string}/_api/#{path}", method_params[:put].to_json )
        elsif method_params.has_key? :delete
          if method_params[:delete] = {}
            JSON.parse RestClient.delete("#{@api_string}/_api/#{path}" )
          else
            JSON.parse RestClient.delete("#{@api_string}/_api/#{path}", method_params[:delete].to_json )
          end
        else
          JSON.parse RestClient.get("#{@api_string}/_api/#{path}")
        end
      end
    end
  end
end