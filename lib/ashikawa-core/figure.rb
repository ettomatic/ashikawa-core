module Ashikawa
  module Core
    # Wrapper around figures of a collection
    class Figure
      # Create a wrapper around given figures
      #
      # @param [Hash] raw_figure
      # @api public
      def initialize(raw_figure)
        @datafiles = raw_figure["datafiles"]
        @alive = raw_figure["alive"]
        @dead = raw_figure["dead"]
      end

      # The number of active datafiles
      #
      # @return Fixnum
      # @api public
      def datafiles_count
        @datafiles["count"]
      end

      # The total size in bytes used by all living documents
      #
      # @return Fixnum
      # @api public
      def alive_size
        @alive["size"]
      end

      # The number of living documents
      #
      # @return Fixnum
      # @api public
      def alive_count
        @alive["count"]
      end

      # The total size in bytes used by all dead documents
      #
      # @return Fixnum
      # @api public
      def dead_size
        @dead["size"]
      end

      # The number of dead documents
      #
      # @return Fixnum
      # @api public
      def dead_count
        @dead["count"]
      end
    end
  end
end
