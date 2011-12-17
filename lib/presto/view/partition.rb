module Presto::View
  class Partition

    include Config

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
