module Ashikawa
  module Core
    # Wrapper around the status of a collection
    class Status
      # Create a wrapper around a given status
      #
      # @param [Fixnum] code
      # @api public
      def initialize(code)
        @code = code
      end

      # Checks if the collection is new born
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection new born?
      #   status = Ashikawa::Core::Status.new 3
      #   status.new_born? #=> false
      def new_born?
        @code == 1
      end

      # Checks if the collection is unloaded
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection unloaded?
      #   status = Ashikawa::Core::Status.new 3
      #   status.unloaded? #=> false
      def unloaded?
        @code == 2
      end

      # Checks if the collection is loaded
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection loaded?
      #   status = Ashikawa::Core::Status.new 3
      #   status.loaded? #=> true
      def loaded?
        @code == 3
      end

      # Checks if the collection is in the process of being unloaded
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection unloaded?
      #   status = Ashikawa::Core::Status.new 3
      #   status.being_unloaded? #=> false
      def being_unloaded?
        @code == 4
      end

      # Checks if the collection is corrupted
      #
      # @return [Boolean]
      # @api public
      # @example Is the collection corrupted?
      #   status = Ashikawa::Core::Status.new 3
      #   status.corrupted? #=> false
      def corrupted?
        @code > 5
      end
    end
  end
end
