module Presto
  module Api

    module InstanceMixin

      # the actual constructor for Presto nodes.
      # Presto initialize an response object on each request.
      # then, the response instance, using this constructor
      # to initialize the node containing the requested action.
      #
      # @example
      #    # if you strongly need to have an own constructor for some node,
      #    # please define a callback to be executed on node initialization,
      #    # by using +node.on_init+ syntax:
      #
      #      node.on_init do
      #        # some logic
      #      end
      #    # you can also override this method and call super on it,
      #    # however it is recommended to use callbacks instead.
      #
      # @param env
      # @param [Symbol] action
      # @param response
      def initialize env, action, response

        # Note! never set response as instance variable,
        # this will allow to bypass sandbox.

        @__presto_api_http_instance__ = Presto::HTTP::InstanceApi.new(self, env, action, response)
        @__presto_api_view_instance__ = Presto::View::InstanceApi.new(self, action)

        (init_proc = node.on_init) && self.instance_exec(&init_proc)
      end

      # reader for HTTP Api.
      # @return instance of {Presto::HTTP::InstanceApi}
      def http api = nil
        @__presto_api_http_instance__ = api if api
        @__presto_api_http_instance__
      end

      # reader for View Api
      # @return instance of {Presto::View::InstanceApi}
      def view
        @__presto_api_view_instance__
      end

      # reader for node Api.
      # @return reference to #node Api, stored at class level
      def node
        self.class.node
      end
    end

    # extending the nodes that included Presto::Api
    def self.included node

      class << node
        # set and/or get node Api
        # @return instance of Presto::Node
        def node
          @__presto_api_node_class__ ||= Presto::Node.new(self)
        end

        # set and/or get HTTP Api
        # @return instance of Presto::HTTP::ClassApi
        def http
          @__presto_api_http_class__ ||= Presto::HTTP::ClassApi.new(self)
        end

        # set and/or get View Api
        # @return instance of Presto::View::Api
        def view
          @__presto_api_view_class__ ||= Presto::View::Api.new(self)
        end
      end

      node.class_exec do
        # using #include to exclude #http, #view and #node from served paths.
        include InstanceMixin
      end

      # adding current node to list of nodes to be served
      Presto.nodes << node

    end
  end
end
