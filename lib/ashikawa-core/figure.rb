module Ashikawa
  module Core
    # Wrapper around figures of a collection
    class Figure
      # Create a wrapper around given figures
      #
      # @param [Hash] raw_figure
      # @api public
      # @example Create a new figure from a raw figure
      #   figure = Ashikawa::Core::Figure.new raw_figure
      def initialize(raw_figure)
        @datafiles = raw_figure["datafiles"]
        @alive = raw_figure["alive"]
        @dead = raw_figure["dead"]
      end

      # The number of active datafiles
      #
      # @return Fixnum
      # @api public
      # @example Get the number of datafiles
      #   figure = Ashikawa::Core::Figure.new raw_figure
      #   figure.datafiles_count #=> 1337
      def datafiles_count
        @datafiles["count"]
      end

      # The total size in bytes used by all living documents
      #
      # @return Fixnum
      # @api public
      # @example Get the size of all living documents in bytes
      #   figure = Ashikawa::Core::Figure.new raw_figure
      #   figure.alive_size #=> 1337
      def alive_size
        @alive["size"]
      end

      # The number of living documents
      #
      # @return Fixnum
      # @api public
      # @example Get the number of living documents
      #   figure = Ashikawa::Core::Figure.new raw_figure
      #   figure.alive_count #=> 1337
      def alive_count
        @alive["count"]
      end

      # The total size in bytes used by all dead documents
      #
      # @return Fixnum
      # @api public
      # @example Get the size of all dead documents in bytes
      #   figure = Ashikawa::Core::Figure.new raw_figure
      #   figure.dead_size #=> 1337
      def dead_size
        @dead["size"]
      end

      # The number of dead documents
      #
      # @return Fixnum
      # @api public
      # @example Get the number of dead documents
      #   figure = Ashikawa::Core::Figure.new raw_figure
      #   figure.dead_count #=> 1337
      def dead_count
        @dead["count"]
      end
    end
  end
end
