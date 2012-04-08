module Ashikawa
  module Core
    class Collection
      # The name of the collection, must be unique.
      attr_reader :name
      
      # The ID of the collection. Is set by the database and unique.
      attr_reader :id
      
      # Create a new Collection object with a name and an optional ID
      # 
      # @param [Database] database The database the connection belongs to
      # @param [Hash] raw_collection The raw collection returned from the server
      def initialize(database, raw_collection)
        @name = raw_collection['name'] if raw_collection.has_key? 'name'
        @id  = raw_collection['id'].to_i if raw_collection.has_key? 'id'
        # @id = options[:id] if options.has_key? :id
      end
    end
  end
end