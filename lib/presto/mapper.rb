module Presto
  class Mapper

    include Presto::InternalUtils
    
    # generates map for a given node.
    # here is where the configs like root, path_rules, canonical are used.
    # `root' is given when namespace are mounted and is used as prefix for node mapped here.
    # `path_rules' is about how the method names will translated into HTTP path.
    # `canonical' is an additional root on which the node will listen on.
    #
    # @param [Class] node to be mapped. should be a valid Presto node,
    #  in terms that it should include Presto::Api and call http.map
    # @return the map of given node.
    def map partition, node

      node_roots = [partition.root + node.http.root]
      node.http.canonical.each { |p| node_roots << p }

      node_roots = node_roots.map { |r| r.gsub(/\/+/, '/') }.uniq

      map = Hash.new
      node_actions(node).each do |action|

        map[action] = Hash.new
        node_roots.each do |root|

          path_rules = node.http.path_rules

          path, routes = action_to_path(action.to_s, path_rules), Array.new
          ([action].concat(node.http.alias[action]||[])).each do |a|
            routes.concat action_routes(a, root, path_rules)
          end
          map[action][:path] ||= path
          map[action][:route] ||= root + path
          map[action][:routes] ||= Array.new
          map[action][:routes].concat routes
        end
      end
      map
    end

    private
    # extracts the methods to be translated into HTTP paths.
    # only public and non-inherited methods extracted.
    # if node has no such methods, auto-generating #index with some placeholder text.
    #
    # @param [Class] node to extract methods from
    # @return [Array] array of methods to be translated
    def node_actions node
      actions = node.instance_methods(false)
      if actions.size == 0
        node.send(:define_method, :index) do |*args|
          'This is just a placeholder text. Get rid of it by defining %s#index' % node
        end
        actions = [:index]
      end
      actions
    end

    # translate an method name to HTTP path
    #
    # @param [Symbol] action the name of method to be translated.
    # @param [String] root prefix
    # @param [Hash] path_rules translation map
    # @return [Array] HTTP paths on which the method will listen on.
    def action_routes action, root, path_rules
      route = root + action_to_path(action.to_s, path_rules)
      [
          route,
          (root if action == :index),
      ].compact.uniq
    end

  end
end
