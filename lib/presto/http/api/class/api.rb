module Presto
  module HTTP
    class ClassApi

      include SharedApi
      include Config

      attr_reader :root, :hooks_a, :hooks_z

      # initializing the HTTP Api to be used at class level.
      #
      # @param [Class] node
      def initialize node
        super
        @node = node
        @canonical = Array.new
        @hooks_a = Hash.new
        @hooks_z = Hash.new
        @alias = Hash.new
      end

      # setting node's root path.
      # only mapped nodes will respond to HTTP requests.
      #
      # @attribute root
      # @param [String, Symbol] path
      # @return [String]
      def map path = nil
        @root = rootify_path(path).freeze if configurable?
      end

      # allow node to resolve to both its real root and canonical root(s).
      # @example
      #    http.map "/pages"
      #    http.canonical "/", "/cms"
      #
      #    def some_action
      #    ...
      #    end
      #
      #    # now node will respond to:
      #    # /pages/some_action
      #    # /cms/some_action
      #    # /some_action
      #
      # @attribute canonical
      # @param [Array]
      def canonical *paths
        @canonical = paths.map { |p| rootify_path(p) } if paths.size > 0 && configurable?
        @canonical
      end

      # hooks to be executed before/after each action
      # @example
      #    http.before { puts "will be executed before each action" }
      #    http.before :index { puts "will be executed only before :index" }
      #
      # @param [Array] actions
      # @param [Proc] proc
      def before *actions, &proc
        return unless configurable?
        actions = ['*'] if actions.size == 0
        actions.each { |a| @hooks_a[a] = proc } if proc
      end

      # (see #before)
      def after *actions, &proc
        return unless configurable?
        actions = ['*'] if actions.size == 0
        actions.each { |a| @hooks_z[a] = proc } if proc
      end

      # allow any action to serve multiple paths.
      #
      # @example make #articles to serve /article and /article.html
      #    def article
      #    end
      #    http.alias :article, :article____html
      #
      # @example make #page to serve /page and /old-page
      #    def page
      #    end
      #    http.alias :page, :old___page
      #
      # @attribute alias
      # @param [Symbol] action
      # @param [Array] aliases
      def alias action = nil, *aliases
        @alias[action] = aliases if action && aliases.size > 0 && configurable?
        @alias
      end

      # turn current node into a file server.
      #
      # @attribute file_server
      # @param [String] root
      # @param [Hash] opts
      # @param [Proc] proc
      def file_server root = nil, opts = {}, &proc
        if root && configurable?
          opts[:cache_control] ||= 'max-age=3600, must-revalidate'
          @file_server = {root: root, opts: opts, proc: proc}
        end
        @file_server
      end

      private
      def configurable?
        # !@node.node.mounted? could also be used,
        # but negations negate positiveness :)
        @node.node.mounted? ? false : true
      end

    end
  end
end
