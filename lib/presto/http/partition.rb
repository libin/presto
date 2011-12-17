module Presto
  module HTTP
    class Partition

      include Config

      # initializing HTTP configuration Api for a mounted partition.
      # see {Presto::Partition#initialize}
      def initialize partition
        super
        @partition = partition
      end

      private
      def configurable?
        @partition.configured? ? false : true
      end

    end
  end
end
