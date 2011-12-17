module Presto
  class App

    # initializing new App
    #>
    #   app = Presto::App.new
    def initialize
      @partitions = Array.new
    end

    # mounting a namespace into a given root and optionally configure mounted partition.
    # nodes under given namespace will use here setup beside own internal setup.
    # @example
    #    app = Presto::App.new
    #    app.mount SomeNamespace do |partition|
    #      # locking all nodes
    #      partition.http.auth {|u,p| [u,p] == ['admin', 'ssp']}
    #      # middleware to be used by all nodes
    #      partition.http.use SomeMiddleware, 'with', 'some' => 'args'
    #      # defining view root for all nodes
    #      partition.view.root '/some/path'
    #      # etc
    #    end
    #
    # @param [Class, Module] namespace containing an arbitrary number of Presto nodes.
    # @param [String, Symbol] root on which the namespace will be mounted, defaulted to / if no path given.
    # @param [Proc] proc used to config mounted partition
    def mount namespace, root = nil, &proc
      @partitions << Presto::Partition.new(namespace, root, &proc)
    end

    # generates an Rack app.
    def map

      if @partitions.size == 0
        # if no partitions mounted, mounting all nodes that included Presto::Api
        @partitions = Presto.nodes.map { |n| n.node.partition }.compact.uniq
      end

      if @partitions.size == 0
        puts
        puts '*'*50
        puts ' ... No partitions nor nodes mounted, exiting ...'
        puts '*'*50
        puts
        exit 1
      end
      
      partitions, presto_middleware = @partitions, Presto.middleware || Array.new
      ::Rack::Builder.new do |builder|

        partitions.each do |partition|
          partition.nodes.select { |n| n.node.mounted? }.each do |node|
            node.node.map.each_pair do |action, map|
              map[:routes].each do |route|
                builder.map route do
                  
                  # middleware used by all nodes, unconditionally
                  presto_middleware.each do |m|
                    use m[:ware], *m[:args], &m[:block]
                  end

                  # middleware used by all partition's nodes
                  node.node.partition.http.middleware.each do |m|
                    use m[:ware], *m[:args], &m[:block]
                  end

                  # middleware used only by current node
                  node.http.middleware.each do |m|
                    use m[:ware], *m[:args], &m[:block]
                  end

                  run Presto::HTTP::Response.new(node, action)
                end
              end
            end
          end
        end
      end
    end

    # output the map of current app
    def show_map
      map if @partitions.size == 0
      @partitions.each do |partition|
        partition.nodes.reject { |n| n.node.map.nil? }.each do |node|
          puts
          puts node
          node.node.map.each_pair do |action, map|
            puts ' - ' + action.to_s
            map[:routes].each { |r| puts "\t" + r }
          end
        end
      end
    end

  end
end
