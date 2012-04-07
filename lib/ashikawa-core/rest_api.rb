require "rest-client"
require "json"

module Ashikawa
  module Core
    class RestApi
      class << self
        attr_accessor :api_string
      end
      
      def RestApi.request(path, method_params = {})
        path.gsub! /^\//,''
        
        if method_params.has_key? :post
          JSON.parse RestClient.post("#{@api_string}/#{path}", method_params[:post])
        else
          JSON.parse RestClient.get("#{@api_string}/#{path}")
        end
      end
    end
  end
end