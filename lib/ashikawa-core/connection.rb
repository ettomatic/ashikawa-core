require "rest-client"
require "json"

module Ashikawa
  module Core
    class Connection
      # The IP for the connection
      # 
      # @return [String]
      # @api public
      attr_reader :ip
      
      # The Port for the connection
      # 
      # @return [Fixnum]
      # @api public
      attr_reader :port
      
      # Initialize a Connection with a given API String
      # 
      # @param [String] IP and Port as a String
      # @api public
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
          JSON.parse RestClient.post("#{@api_string}/#{path}", method_params[:post])
        elsif method_params.has_key? :put
          JSON.parse RestClient.put("#{@api_string}/#{path}", method_params[:put])
        elsif method_params.has_key? :delete
          JSON.parse RestClient.delete("#{@api_string}/#{path}", method_params[:delete])
        else
          JSON.parse RestClient.get("#{@api_string}/#{path}")
        end
      end
    end
  end
end