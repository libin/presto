module Presto
  module Utils

    # "fluffing" potentially hostile paths
    # @param [String, Symbol] path
    # @param [Boolean] strip_trailing_slashes
    # @return [String]
    def normalize_path path, strip_trailing_slashes = false
      path = Rack::Utils.unescape(path.to_s.strip).
          gsub(/^\.\.\/|\/\.\.\/|\/\.\.$/, '/').
          gsub(/\/+/, '/')
      path = path.gsub(/^\/|\/$/, '') if strip_trailing_slashes
      path
    end

    module_function :normalize_path

    # transform any path into absolute path
    # @param [String, Symbol] path
    # @return [String]
    def rootify_path path
      path = normalize_path(path, true)
      path.size > 0 ? '/%s/' % path : '/'
    end

    module_function :rootify_path

    # takes an arbitrary number of arguments and builds an HTTP path.  
    # Hash arguments will transformed into HTTP params.  
    # empty hash elements will be ignored.
    # @example
    #    Presto::Utils.build_path :some, :page, and: :some_param
    #    #=> some/page?and=some_param
    #    Presto::Utils.build_path 'another', 'page', with: {'nested' => 'params'}
    #    #=> another/page?with[nested]=params
    #    Presto::Utils.build_path 'page', with: 'param-added', an_ignored_param: nil
    #    #=> page?with=param-added
    #
    # @param [Array] args
    # @return [String]
    def build_path *args
      path, params = Array.new, Hash.new
      args.each { |a| a.is_a?(Hash) ? params.update(a) : path << a.to_s }
      path = path.join('/')
      return path if params.size == 0
      path = [path]
      params.select { |k, v| k && v }.each_pair do |k, v|
        meth = v.is_a?(Hash) ? :build_nested_query : :build_query
        next if (query = ::Rack::Utils.send(meth, k => v)).size == 0
        path << (path.size == 1 ? "?" : "&") + query
      end
      path.join
    end

    module_function :build_path

  end

  module InternalUtils

    include Utils

    STATUS_OK = 200.freeze
    STATUS_REDIRECT = 302.freeze
    STATUS_NOT_FOUND = 404.freeze
    STATUS_SERVER_ERROR = 500.freeze
    STATUS_RESTRICTED = 401.freeze

    # get the namespace of a node.
    #
    # @param [Class] node
    # @return [String]
    def extract_namespace node
      node.ancestors[0].to_s
    end

    # translate a method name to HTTP path.
    #
    # @param [String] action
    # @param [Hash] path_rules
    # @return [String]
    def action_to_path action, path_rules
      path_rules.keys.sort.reverse.each do |key|
        action = action.gsub(/#{key}/, path_rules[key])
      end
      action
    end

    module_function :action_to_path

  end
end
