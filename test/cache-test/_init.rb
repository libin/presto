require ::File.expand_path("../_init", ::File.dirname(__FILE__))

module CacheTests
  module BasicTests

    def test_brackets_syntax

      key = "some key"
      val = "some value"
      @cache[key] = val
      assert_equal @cache[key], val

      key = :some_key
      val = :some_value
      @cache[key] = val
      assert_equal @cache[key], val

      key = 1
      val = 1.2
      @cache[key] = val
      assert_equal @cache[key], val

      key = {some: :key}
      val = [:some, "val"]
      @cache[key] = val
      assert_equal @cache[key], val
    end

    def test_datatype

      @cache.truncate
      val = :val
      @cache[:key] = val
      assert_instance_of Symbol, @cache[:key]

      val = Time.now.utc
      @cache[:key] = val
      assert_instance_of Time, @cache[:key]

      val = [1, 2, 3]
      @cache[:key] = val
      assert_instance_of Array, @cache[:key]

      val = {some: :value}
      @cache[:key] = val
      assert_respond_to @cache[:key], :each_pair

      val = 1
      @cache[:key] = val
      assert_instance_of Fixnum, @cache[:key]

      val = 1.0
      @cache[:key] = val
      assert_instance_of Float, @cache[:key]

      val = true
      @cache[:key] = val
      assert_instance_of TrueClass, @cache[:key]

    end

    def test_size

      @cache.truncate
      1.upto(10) { |i| @cache[i] = i }
      assert_equal @cache.size, 10
    end

    def test_enumerator

      @cache.truncate
      0.upto(10) { |i| @cache[i] = i }

      @cache.keys.each do |k|
        assert_equal @cache[k], k.to_i
      end
    end

    def test_update

      @cache.truncate

      ds = {"k1" => :v1, "k2" => :v2}
      @cache.update ds

      assert_equal ds.keys, @cache.keys
    end

    def test_values

      c1 = @cache.new(:c1)
      c2 = c1.new(:c2)
      c3 = c2.new(:c3)

      c2[:key] = :val
      assert_equal c2[:key], :val

      c3["some-key"] = :val
      assert_equal c3["some-key"], :val
    end

    def test_filter
      
      items = {'k1' => :v1, 'k2' => :v2}
      cache = @cache.new(__method__)
      items.each_pair do |k,v|
        cache[k] = v
      end

      item = cache.filter(key: 'k1').first
      assert_equal ['k1', :v1], item.values_at('key', 'val')
      assert_equal cache.filter(key: /k/).count, 2
      assert_equal cache.filter(val: :v2).count, 1
    end

    def test_enumerator__keys

      items = {'k1' => :v1, 'k2' => :v2}
      cache = @cache.new(__method__)
      items.each_pair do |k,v|
        cache[k] = v
      end

      assert_equal items.keys, cache.keys

    end

    def test_enumerator__each_key

      items = {'k1' => :v1, 'k2' => :v2}
      cache = @cache.new(__method__)
      items.each_pair do |k,v|
        cache[k] = v
      end

      assert_equal items.keys, cache.keys

    end

    def test_enumerator__values

      items = {'k1' => :v1, 'k2' => :v2}
      cache = @cache.new(__method__)
      items.each_pair do |k,v|
        cache[k] = v
      end

      cached_items = []
      cache.each_key do |key|
        cached_items << key
      end

      assert_equal items.keys, cache.keys

    end
    
    def test_enumerator__each_value

      items = {'k1' => :v1, 'k2' => :v2}
      cache = @cache.new(__method__)
      items.each_pair do |k,v|
        cache[k] = v
      end

      cached_items = []
      cache.each do |val|
        cached_items << val
      end
      assert_equal cached_items, items.values

    end

    def test_enumerator__each_pair

      items = {'k1' => :v1, 'k2' => :v2}
      cache = @cache.new(__method__)
      items.each_pair do |k,v|
        cache[k] = v
      end

      cached_items = {}
      cache.each_pair do |key, val|
        cached_items[key] = val
      end
      assert_equal cached_items, items

    end

    def test_delete

      @cache[:key] = "value"
      @cache.delete(:key)
      assert_nil @cache[:key]

      @cache[:key] = "value"
      @cache.delete(:key)
      assert_nil @cache[:key]

    end

    def test_truncate

      @cache[:key] = "value"
      refute @cache.empty?
      @cache.truncate
      assert @cache.empty?
    end

    def test_drop
      cache = @cache.new __method__
      branch = cache.new :branch
      branch.drop
      assert_nil cache.db(:branch)
    end

  end
end
