require "rest-client"
require "json"

module Ashikawa
  module Core
    class Connection
      class << self
        # An API connection string, for example http://localhost:8529/_api
        # to be used for every following request as base URL.
        attr_accessor :api_string
      end
      
      # Sends a request to a given path. Prepends the api_string automatically.
      # Example call: 
      ## GET request:
      # Connection.request('/collection/new_collection')
      ## POST request:
      # Connection.request('/collection/new_collection', :post => { :name => 'new_collection' })
      #
      # @param [String] path the path you wish to send a request to.
      # @param [Hash] method_params additional parameters for your request. Only needed if you want to send something other than a GET request.
      # @option method_params [Hash] :post POST data in case you want to send a POST request.
      # @return [Hash] parsed JSON response from the server
      def Connection.request(path, method_params = {})
        path.gsub! /^\//, ''
        
        if method_params.has_key? :post
          JSON.parse RestClient.post("#{@api_string}/#{path}", method_params[:post])
        else
          JSON.parse RestClient.get("#{@api_string}/#{path}")
        end
      end
    end
  end
end