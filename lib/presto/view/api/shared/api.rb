module Presto
  module View
    module SharedApi

      include Presto::Utils
      include Presto::View::InternalUtils

      # get the full path to templates, honoring node's root.
      # @return [String]
      def path
        '%s/%s/' % [root, (@node.http.route if @node)]
      end

      # simply caching precompiled templates and reuse next time.
      # this may increase performance, as it will avoid fs operations
      # and wont compile template each time.
      #
      # @param engine
      # @param file
      # @param action
      # @param context
      # @return [String]
      def template engine, file, action = nil, context = nil

        scope = @node_instance || @node || Object.new
        proc = compile(action)
        return engine.new(file) unless proc &&
            instruction = scope.instance_exec(action, &proc)

        pool = compiler_pool
        locals = context.is_a?(Hash) ? context.keys : []
        key = '%s:%s:%s:%s' % [file, @node, action, ::Digest::MD5.hexdigest(locals.to_s)]

        pool[key] = engine.new(file).precompile(*locals) if instruction == :update
        
        template, offset = pool.get key do
          engine.new(file).precompile(*locals)
        end
        engine.new { [template, offset] }
      end

    end
  end
end
