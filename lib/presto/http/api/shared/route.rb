module Presto
  module HTTP
    module SharedApi

      # return node root + action route.
      # any other arguments will be added to path.
      #
      # @example
      #    class RouteTest
      #      include Presto::Api
      #      http.map "/route-test"
      #    end
      #
      #    http.route                         #=> /route_test
      #    http.route(:edit, 1, 2)            #=> /route_test/edit/1/2
      #    http.route(:edit, k: 'v')          #=> /route_test/edit/?k=v
      #    RouteTest.http.route               #=> /route_test/
      #    RouteTest.http.route(:some_method) #=> /route-test/some_method
      #
      # @param [Symbol, nil] action
      # @param [Array] args
      # @return [String]
      def route action = nil, *args

        root = @node.node.partition ? @node.node.partition.root : ''
        path = @node.http.root.to_s

        return root + path unless action

        if @node.node.map && map = @node.node.map[action]
          return map[:route] if args.size == 0
          return map[:route] + "/" + Presto::Utils.build_path(*args)
        end
        root + path + Presto::Utils.build_path(*[action].concat(args))
      end

    end
  end
end
