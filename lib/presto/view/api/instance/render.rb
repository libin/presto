module Presto::View
  class InstanceApi

    # render current action.
    #
    # path built from node.route and action.to_path
    #
    # node's self is used as scope,
    # so all node's instance variables and methods available in template files.
    def render opts = {}

      if engine = opts[:engine]
        # if engine given, using it and its default extension
        ext = guess_extension(engine)
      else
        # otherwise, using default node's engine and ext
        engine, ext = engine(), ext()
      end
      ext = ext.to_s

      args = [scope || @node_instance, opts[:context]]

      file = '%s/%s.%s' % [root, @action_route, ext]
      output = template(engine, file, @action, args[1]).render(*args)

      if layout_name = opts[:layout] || layout[@action] || layout['*']
        file = '%s/%s.%s' % [layouts_root, layout_name, ext]
        output = template(engine, file, @action, args[1]).render(*args) { output }
      end
      output
    end

    ENGINES.each_pair do |label, engine|

      # same as #render, but it defines engine explicitly.
      # if no ext passed, it will be guessed
      define_method "render_#{label.downcase}" do |context={}|
        render(context: context, engine: engine)
      end

    end

  end
end
