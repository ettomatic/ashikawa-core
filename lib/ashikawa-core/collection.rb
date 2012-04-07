module Ashikawa
  module Core
    class Collection
      # The name of the collection
      attr_reader :name
      
      # The ID of the collection
      attr_reader :id
      
      # Create a new Collection object with a name and an optional ID
      # 
      # @param [String] name Name of the collection
      # @param [Hash] options Options to create a collection
      # @option options [Integer] :id The ID of the collection (should not be set manually, leave that to the database)
      def initialize(name, options = {})
        @name = name
        @id = options[:id] if options.has_key? :id
      end
    end
  end
end