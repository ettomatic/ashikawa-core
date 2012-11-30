module Ashikawa
  module Core
    # Wrapper around figures of a collection
    class Figure
      def initialize(raw_figure)
        @datafiles = raw_figure["datafiles"]
        @alive = raw_figure["alive"]
        @dead = raw_figure["dead"]
      end

      # The number of active datafiles
      def datafiles_count
        @datafiles["count"]
      end

      # The total size in bytes used by all living documents
      def alive_size
        @alive["size"]
      end

      # The number of living documents
      def alive_count
        @alive["count"]
      end

      # The total size in bytes used by all dead documents
      def dead_size
        @dead["size"]
      end

      # The number of dead documents
      def dead_count
        @dead["count"]
      end
    end
  end
end
