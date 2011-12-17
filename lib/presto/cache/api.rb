module Presto
  module Cache
    module Api

      KEY = "key".freeze
      VAL = "val".freeze

      attr_reader :store

      def initialize *args
        @args = args
        @mutex = Mutex.new
        @mutex.synchronize do
          @store = initialize_store *@args
        end
        @children = Hash.new
        @callbacks = {a: Hash.new, z: Hash.new}
      end

      # creates a new store, related to current one.
      #
      # @example
      #    global_cache = Presto::Cache::Memory.new
      #    page_cache = global_cache.new(:page)
      #    # now you can access new store by assigned var or by:
      #    #  - global_cache.page
      #    #  - global_cache.db(:page)
      #
      # @param [Symbol, String] name
      #   names are symbolized, so if you use a string as 'name', you'll can access it by **store.db(:name)**
      # @return new store
      def new name
        execute_callbacks :a, __method__, name
        store = self.class.new *@args, name
        @children[name.to_sym] = store
        execute_callbacks :z, __method__, name
        store
      end

      # return earlier created store or create new one
      #
      # @param [Symbol] name
      # @param [Boolean] create_new_if_missing
      #   if true and no store found by given name, will create new one using given name.
      # @return found or new store or nil
      def db name, create_new_if_missing = false
        if db = @children[name]
          wipe = db.store ? db.store.dropped? : true
          wipe && @children.delete(name) && db = nil
        end
        db ||= new(name) if create_new_if_missing
        db
      end

      # searching through related stores and return first found
      # @raise NoMethodError if no store found
      # @return found related store
      def method_missing name
        db(name) || raise(NoMethodError, name.to_s)
      end

      # insert new item or if an item with given key already exists, update it.
      #
      # @param [Symbol, String] key
      # @param val
      # @return val
      def set key, val
        execute_callbacks :a, __method__, key, val
        persisted = false
        @mutex.synchronize do
          if @store[key.to_s] = dump(val)
            persisted = true
          end
        end
        execute_callbacks :z, __method__, key, val
        val if persisted
      end

      # find item by given key.
      # if no item found and proc given,
      # it will create new item using as val the value returned by proc.
      #
      # @example
      #    cache = Presto::Cache::Memory.new
      #    page = cache.get '/about-us.html' do
      #      Page.first(path: '/about-us.html')
      #    end
      #
      # @param [Symbol, String] key
      # @param [Proc] proc
      # @return
      #   Object - if item found or proc given.
      #   nil - if no item found and no proc given.
      def get key, &proc
        execute_callbacks :a, __method__, key
        if val = @store[key.to_s]
          return load(val)
        end
        execute_callbacks :z, __method__, key
        return set(key, proc.call) if proc
        nil
      end

      # filter collection by key and/or value.
      # returns an array of found items or empty array.
      #
      # @example
      #    db = Mongo::Connection.new("localhost", 20_000).db("presto-cache")
      #    store = Presto::Cache::MongoDB.new db
      #    store['item1'] = 'one'
      #    store['item2'] = 'two'
      #    item1 = store.filter key: 'item1'
      #    item2 = store.filter val: 'two'
      #    items = store.filter key: /item/
      #
      #    p item1.first
      #    {"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b614'), "key"=>"item1", "val"=>"one"}
      #
      #    p item2.first
      #    {"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b615'), "key"=>"item2", "val"=>"two"}
      #
      #    items.each do |i|
      #      p i
      #    end
      #    {"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b614'), "key"=>"item1", "val"=>"one"}
      #    {"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b615'), "key"=>"item2", "val"=>"two"}
      #
      #    p items.to_a
      #    [{"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b614'), "key"=>"item1", "val"=>"one"}, {"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b615'), "key"=>"item2", "val"=>"two"}]
      #
      #    store = Presto::Cache::Memory.new
      #    store['item1'] = 'one'
      #    store['item2'] = 'two'
      #    item1 = store.filter key: 'item1'
      #    item2 = store.filter val: 'two'
      #    items = store.filter key: /item/
      #
      #    p item1.first
      #    {"key"=>"item1", "val"=>"one"}
      #
      #    p item2.first
      #    {"key"=>"item2", "val"=>"two"}
      #
      #    items.each do |i|
      #      p i
      #    end
      #    {"key"=>"item1", "val"=>"one"}
      #    {"key"=>"item2", "val"=>"two"}
      #
      # @param [Hash] filters
      # @option filters [String, Regexp] :key
      # @option filters [String, Regexp] :val
      # @return [Array]
      def filter filters = {}
        filter = {}
        if key = filters[:key] || filters['key'] || filters[:k] || filters['k']
          filter[KEY] = key
        end
        if val = filters[:val] || filters['val'] || filters[:v] || filters['v']
          filter[VAL] = val
        end
        @store.filter filter
      end

      # a simple wrapper around #filter.
      #
      # @param [Array] args
      # @return
      #   first item from array returned by #filter or nil if no items found.
      def first *args
        filter(*args).first
      end

      # updates an arbitrary amount of items by given keys.
      #
      # @example
      #    store['item1'] = 'one'
      #    store['item2'] = 'two'
      #
      #    p store.filter.to_a
      #    [{"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b614'), "key"=>"item1", "val"=>"one"}, {"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b615'), "key"=>"item2", "val"=>"two"}]
      #
      #    store.update 'item1' => 'oneUpdated', 'item2' => 'twoUpdated'
      #    p store.filter.to_a
      #    [{"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b614'), "key"=>"item1", "val"=>"oneUpdated"}, {"_id"=>BSON::ObjectId('4edee68a73726b0d24f2b615'), "key"=>"item2", "val"=>"twoUpdated"}]
      #
      # @param [Hash] hash
      #   containing key of item to be updated and new value.
      # @return
      #   true - if all updates passed.
      #   false - if at least one operation failed.
      def update hash
        persisted = true
        execute_callbacks :a, __method__, hash
        @mutex.synchronize do
          hash.each_pair { |k, v| (@store[k.to_s] = v) || persisted = false }
        end
        execute_callbacks :z, __method__, hash
        persisted
      end

      # delete an item by key.
      #
      # @param [Symbol, String] key
      def delete key
        persisted = false
        execute_callbacks :a, __method__, key
        @mutex.synchronize do
          persisted = @store.delete(key.to_s)
        end
        execute_callbacks :z, __method__, key
        persisted
      end

      # remove all items from an collection.
      #
      # @param [Boolean] recursive
      #  if true, it will act recursively, truncating all children and children of children.
      # @return [nil, true]
      def truncate recursive = nil
        status = nil
        execute_callbacks :a, __method__, recursive
        recursive && @children.each_value { |s| @mutex.synchronize { status = s.truncate(recursive) } }
        @mutex.synchronize { @store.truncate }
        execute_callbacks :z, __method__, recursive
        status
      end

      # removing an entire collection.
      #
      # @param (see #truncate)
      # @return (see #truncate)
      def drop recursive = nil
        status = nil
        execute_callbacks :a, __method__, recursive
        recursive && @children.each_pair { |n, s| @mutex.synchronize { status = s.drop(recursive) && @children.delete(n) } }
        @mutex.synchronize { @store.drop }
        @store = nil
        execute_callbacks :z, __method__, recursive
        status
      end

      # set an callback to be executed before/after action(s).
      #
      # @note
      #   # list of actions executing callbacks:
      #      - new
      #      - insert
      #      - set
      #      - get
      #      - update
      #      - delete
      #      - truncate
      #      - drop
      # @note
      #   all args will be passed back to callback.
      #
      # @example
      #    store.before :new do |name|
      #      p 'creating %s store' % name
      #    end
      #
      #    store.new :articles
      #    "creating articles store"
      #
      #    store.before :set do |key, val|
      #      p 'inserting: %s => %s' % [key, val]
      #    end
      #    store['alert'] = 'page updated'
      #    "inserting: alert => page updated"
      #
      # @param [Array] actions list of actions.
      #  if no args given, callback to be executed before/after any action.
      def before *actions, &proc
        actions = ['*'] if actions.size == 0
        actions.each { |a| @callbacks[:a][a] = proc }
      end

      # (see #before)
      def after *actions, &proc
        actions = ['*'] if actions.size == 0
        actions.each { |a| @callbacks[:z][a] = proc }
      end

      # list of related stores
      def dbs
        @children.keys
      end

      # insert new item or update found one
      def []= key, val
        set key, val
      end

      # find a item by key
      def [] key
        get key
      end

      # same as Hash#keys
      def keys
        @store.keys
      end

      # same as Hash#values
      def values
        keys.each.map { |k| get(k) }
      end

      # same as Hash#each_value
      def each
        filter.map { |i| yield i['val'] }
      end

      alias :each_value :each

      # same as Hash#each_key
      def each_key
        filter.map { |i| yield i['key'] }
      end

      # same as Hash#each_pair
      def each_pair
        filter.map { |i| yield i['key'], i['val'] }
      end

      # items count
      def size
        @store.size
      end

      alias :count :size

      def empty?
        @store.size == 0
      end

      private

      def dump val
        @store.serialize ? Marshal.dump(val) : val
      end

      def load val
        @store.serialize ? Marshal.load(val) : val
      end

      def execute_callbacks type, meth, *args
        [@callbacks[type]['*'], @callbacks[type][meth]].compact.each { |c| c.call(*args) }
      end

    end
  end
end
