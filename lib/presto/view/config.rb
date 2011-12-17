module Presto
  module View

    # @note
    #   configs here are set by both node and partition
    #
    # @note
    #   methods here used to setup the View Api.  
    #   to have an consistent setup, it should be write-able only at class definition.  
    #   any later updates should be prohibited.  
    #   to accomplish this, any updates for mounted nodes are silently dropped.
    #
    # @example
    #    class App
    #
    #      # configuring Api at class level
    #      view.root '/some/path'
    #      view.engine :Haml
    #
    #      # trying to modify configs at instance level
    #      http.before do
    #        view.root '/path/to/offending/templates' # this will be simply ignored cause root already set
    #        p view.root #=> "/some/path"
    #      end
    #    end
    module Config

      include Presto::Utils

      attr_reader :layouts

      def initialize *args
        @setup = Hash.new
        @compile = Hash.new
      end

      # set engine to be used.
      #
      # @example
      #    http.engine :Haml
      #
      # @param [Symbol] engine
      #   accepts any of Tilt supported engine
      # @param [String] ext
      #   extension to be used. by default it takes engine's default extension.
      def engine engine = nil, ext = nil
        if engine && configurable?
          @engine = engine_supported?(engine)
          @ext = ext || guess_extension(@engine)
        end
        @setup[:engine] ||= @engine ||
            (@node.node.partition.view.engine if @node) ||
            Presto.opts.view.engine
      end

      # set the path where templates resides.
      # @note
      #   only absolute paths will work.
      def root path = nil
        @root = rootify_path(path) if path && configurable?
        @setup[:root] ||= @root || (@node.node.partition.view.root if @node)
      end

      # set the extension used by templates
      def ext ext = nil
        @ext = ext if ext && configurable?
        @setup[:ext] ||= @ext ||
            (@node.node.partition.view.ext if @node) ||
            Presto.opts.view.ext
      end

      # set the layout to be used by some or all actions
      #
      # @param [String] layout
      # @param [Array] *actions
      #   list of actions to use layout. if ignored, all actions will use given layout.
      def layout layout = nil, *actions
        if layout && configurable?
          @layouts ||= Hash.new
          actions = ['*'] if actions.size == 0
          actions.each { |a| @layouts[a] = layout }
        end
        @setup[:layouts] ||= @layouts ||
            (@node.node.partition.view.layouts if @node) ||
            Hash.new
      end

      # set the path where app will look for layouts.
      # @note
      #   only absolute paths will work.
      def layouts_root path = nil
        @layouts_root = rootify_path(path) if path && configurable?
        @setup[:layouts_root] ||= @layouts_root ||
            root ||
            (@node.node.partition.view.layouts_root if @node) ||
            (@node.node.partition.view.root if @node)
      end

      # set the custom scope for rendered templates.
      # if no scope set, it will use the scope where the #view.render called.
      def scope scope = nil
        @scope = scope if scope && configurable?
        @setup[:scope] ||= @scope ||
            (@node.node.partition.view.scope if @node)
      end

      # for most apps, most expensive operations are fs operations  
      # and template compilation. it is possible to avoid these operations  
      # by storing compiled templates in memory and just render them later.
      #
      # this method allow to enable compiler for all or just some actions.  
      # actions should be passed one by one as arguments.  
      # if no args passed, all actions will use compiler.
      #
      # **compiler behavior are determined by given block.**
      #
      # * if block returns any positive value, compiled template will be used.
      # * if block returns :update [Symbol], compiled template will be updated and used.
      #
      # @note
      #   compiler will work only if block given
      #
      # @example compile templates for all actions
      #    view.compile { true }
      #
      # @example compile templates only for #summary and #content
      #    view.compile(:summary, :content) { true }
      #
      # @example update cache as needed
      #    view.compile do
      #      :update if http.params['update-compiler']
      #    end
      #
      #    view.compile do |action|
      #      :update if action == :content && http.params['update-content']
      #    end
      #
      # @param [Array] *actions
      # @param [Proc] &proc
      def compile *actions, &proc

        if proc && configurable?
          actions = ['*'] if actions.size == 0
          actions.each { |a| @compile[a] = proc }
        end

        action = actions.first
        @setup['%s::%s' % [:compile, action]] ||= @compile[action] ||
            @compile['*'] ||
            (@node.node.partition.view.compile(action) if @node)
      end

      # by default, compiled templates kept in memory.
      # this option allow to use custom pool.
      # @example using MongoDB pool for compiled templates
      #    db = Mongo::Connection.new.db('compiler-pool')
      #    view.compiler_pool Presto::Cache::MongoDB.new(db)
      #
      def compiler_pool pool = nil
        @compiler_pool = pool if pool && configurable?
        @setup[:compiler_pool] ||= @compiler_pool ||
            (@node.node.partition.view.compiler_pool if @node) ||
            ::Presto::Cache::Memory.new
      end

    end
  end
end
