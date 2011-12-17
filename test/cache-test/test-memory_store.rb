require ::File.expand_path("_init", ::File.dirname(__FILE__))

module MemoryTest

  class MasterStore < MiniTest::Unit::TestCase
    
    include CacheTests::BasicTests

    def setup
      @cache = Presto::Cache::Memory.new
    end

  end

  class NestedStore < MiniTest::Unit::TestCase

    include CacheTests::BasicTests

    def setup
      master = Presto::Cache::Memory.new
      branch1 = master.new(:branch1)
      branch2 = branch1.new(:branch2)
      branch3 = branch2.new(:branch3)
      @cache = branch3
    end

  end
end
