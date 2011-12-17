module Presto::View
  class InstanceApi

    include SharedApi

    def initialize node_instance, action
      @node, @node_instance = node_instance.class, node_instance
      @action = action
      @action_route = @node.node.map[action][:route] if @node.node.map
      @layout = Hash.new
    end

    [
        :root,
        :engine,
        :ext,
        :layout,
        :layouts_root,
        :compile,
        :compiler_pool,
        :scope,
    ].each do |meth|
      define_method meth do |*args|
        @node.view.send meth, *args
      end
    end
  end
end
