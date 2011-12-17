module Presto
  module Cache
    class MongoDB

      include Api

      def initialize_store *args
        Store.new *args
      end

      class Store

        attr_reader :serialize

        # check that the save succeeded.
        # false by default
        attr_accessor :safe

        def initialize db, *chain
          @db = db
          @table_name = chain.size > 0 ? chain.map { |i| i.to_s }.join("_") : "master"
          @table = initialize_table()
        end

        def insert key, val
          @table.insert Api::KEY => key, Api::VAL => val
        end

        def []= key, val
          @table.update(
              {Api::KEY => key},
              {Api::KEY => key, Api::VAL => val},
              {upsert: true, safe: @safe}
          )
        end

        def [] key
          return unless item = @table.find_one(Api::KEY => key)
          item[Api::VAL]
        end

        def filter filters = {}
          @table.find filters
        end

        def keys
          @table.distinct(Api::KEY)
        end

        def size
          keys.size
        end

        def delete key
          @table.remove(Api::KEY => key)
        end

        def truncate
          @table.remove
        end

        def drop
          @table.drop && @dropped = true
        end

        def dropped?
          @dropped
        end

        private

        def initialize_table

          collection = lambda do |new=false|
            @db.create_collection(@table_name) if new
            @db.collection(@table_name)
          end
          table = collection.call || collection.call(true)
          table.create_index Api::KEY
          table
        end

      end
    end
  end
end
