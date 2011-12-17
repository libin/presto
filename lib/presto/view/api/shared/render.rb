module Presto
  module View
    module SharedApi

      # renders a view file which path is built from view_root and given_path.
      # carrying layout
      #
      # if path is an symbol, and there are an node method with same name,
      # path is taken from { method => [paths] } map.
      #
      # if path starts with slash, root will not be prepended
      #
      # if no extension found in path, it will be searched in node setup,
      # or guessed by engine when engine given explicitly.
      #
      # **regard context:**  
      #   *when it is an Hash:*  
      #    - scope is node's instance or node's class  
      #    - locals are given hash.
      #
      #   *when it is an instance or nil:*  
      #    - scope is given instance or nil.  
      #    - locals are nil.
      #
      def render_view path_or_action, context = nil, engine = nil, engine_ext = nil, layout_name = nil

        action = nil
        if @node && map = @node.node.map[path_or_action]

          # 1st param is an action.
          action = path_or_action
          path = map[:path].sub(/^\/+/, '')

          # for now, using default extension
          ext = ext()
        else
          # splitting given path into path and extension
          path, ext = split_path(path_or_action)
        end

        # use default engine when no engine given
        engine ||= engine()

        # override any ext if engine_ext given
        ext = engine_ext if engine_ext
        # if no extension found above, use default one or guess it by engine
        ext ||= ext() || guess_extension(engine)

        if path[0] == '/'
          file = '%s.%s' % [path, ext]
        else
          file = '%s/%s.%s' % [path(), path, ext]
        end

        args = context_to_args(context)
        output = template(engine, file, @action, args[1]).render(*args)
        return output if layout_name == false

        if layout_name = layout[action] || layout['*']
          file = '%s/%s.%s' % [layouts_root, layout_name, ext]
          output = template(engine, file, @action, args[1]).render(*args) { output }
        end
        output
      end

      # render an action or an file without layout
      def render_partial path_or_action = nil, context = nil, engine = nil, engine_ext = nil

        # useful on instance api.
        # it allows to render an action without layout just with
        # view.render_partial
        path_or_action ||= @action

        render_view path_or_action, context, engine, engine_ext, false
      end

      # render an layout file.
      # output to be yielded should be passed as first argument.
      def render_layout output = nil, context = nil, engine = nil, ext = nil
        if layout_name = layout[@action] || layout['*']
          engine ||= engine()
          ext ||= ext() || guess_extension(engine)
          args = context_to_args(context)
          file = '%s/%s.%s' % [layouts_root, layout_name, ext]
          output = template(engine, file, @action, args[1]).render(*args) { output.to_s }
        end
        output
      end

      ENGINES.each_pair do |label, engine|

        # same as #render_view except it defines engine explicitly
        define_method :"render_#{label.downcase}_view" do |path, context={}|
          render_view(path, context, engine, guess_extension(engine))
        end

        # same as #render_partial except it defines engine explicitly
        define_method :"render_#{label.downcase}_partial" do |path, context={}|
          render_view(path, context, engine, guess_extension(engine), false)
        end

        # same as #render_layout except it defines engine explicitly
        define_method :"render_#{label.downcase}_layout" do |output, context={}|
          render_layout(output, context, engine, guess_extension(engine))
        end

      end

    end
  end
end
