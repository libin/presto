require "mongo"
require ::File.expand_path("_init", ::File.dirname(__FILE__))

module MongoDBTest

  DB = MONGODB_CONN.db('presto-cache_test')

  class MasterStore < MiniTest::Unit::TestCase
    
    include CacheTests::BasicTests

    def setup
      @cache = Presto::Cache::MongoDB.new( DB )
    end

    def teardown
      @cache.drop true
    end

  end

  class NestedStore < MiniTest::Unit::TestCase

    include CacheTests::BasicTests

    def setup
      @master = Presto::Cache::MongoDB.new( DB )
      branch1 = @master.new(:branch1)
      branch2 = branch1.new(:branch2)
      branch3 = branch2.new(:branch3)
      @cache = branch3
    end

    def teardown
      @master.drop true
    end

  end
end
