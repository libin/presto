module Presto
  module HTTP
    class InstanceApi

      # simply pass control to another action.
      # by default it will pass control to an action on current node.
      # if node given, control will be passed to an action on given node.
      # if proc given, it will be executed just before leaving current scope.
      #
      # @example pass control to #control_panel if user logged in
      #    def index
      #      http.fwd(:control_panel) if http.user
      #    end
      #
      # @example execute a callback before leaving current scope
      #    http.before do |action, *args|
      #      if args.size > 0
      #        http.fwd :catchall do
      #          puts 'control passed to #catchall with args: %s' % args
      #        end
      #      end
      #    end
      #
      # @example passing control to inner node
      #    http.fwd :some_action, SomeNode
      #
      # @example modify env before leaving current scope
      #    http.fwd :some_action do |env|
      #      env['PATH_INFO'] = '/this/way/is-possible/to-pass/modified-params/to-target-action'
      #    end
      #
      # @param [Symbol] action
      # @param [Class] node
      # @param [Proc] proc
      def fwd action, node = @node, &proc
        @node_instance.instance_exec(@request.env, &proc) if proc
        throw :__presto_catch_response__, Response.new(node, action).call(@request.env)
      end

      alias :pass :fwd

    end
  end
end
