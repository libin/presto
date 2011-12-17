module Presto
  module Cache
    class Memory

      include Api

      def initialize_store *args
        @store = Store.new
      end

      class Store

        attr_reader :serialize

        def initialize
          @store = Hash.new
        end

        def []= key, val
          @store[key] = val
        end

        def [] key
          @store[key]
        end

        def filter filters = {}
          key, val = filters.values_at(Api::KEY, Api::VAL)
          cmp = lambda { |f, v| f.is_a?(Regexp) ? v =~ f : v == f }
          items = lambda { key ? @store.select { |k, v| cmp.call(key, k) } : @store }
          push = lambda { |k, v| {Api::KEY => k, Api::VAL => v} }
          filter_by_key = lambda do
            results = []
            items.call.each_pair { |k, v| results << push.call(k, v) }
            results
          end
          filter_by_key_and_val = lambda do
            results = []
            items.call.each_pair { |k, v| cmp.call(val, v) && results << push.call(k, v) }
            results
          end
          val ? filter_by_key_and_val.call : filter_by_key.call
        end

        def size
          @store.size
        end

        def keys
          @store.keys
        end

        def delete k
          @store.delete k
        end

        def truncate
          @store.clear
        end

        def drop
          @store.clear && @dropped = true
        end

        def dropped?
          @dropped
        end
      end

    end
  end
end
