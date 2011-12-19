module Presto::View
  class InstanceApi

    # render current action.
    #
    # path built from node.route and action.to_path
    #
    # node's self is used as scope,
    # so all node's instance variables and methods available in template files.
    def render *scope_and_or_context
      render_action engine(), ext() || guess_extension(engine()), *scope_and_or_context
    end

    ENGINES.each_pair do |label, engine|

      # same as #render, but it defines engine explicitly.
      # if no ext passed, it will be guessed
      define_method "render_#{label.downcase}" do |*scope_and_or_context|
        render_action engine, guess_extension(engine), *scope_and_or_context
      end

    end
    
    def render_action engine, ext, *scope_and_or_context

      scope, context = guess_scope_and_context *scope_and_or_context

      file = '%s/%s.%s' % [root(), @action_route, ext]
      output = template(engine, file, @action, context).render(scope, context)

      if layout_name = layout[@action] || layout['*']
        file = '%s/%s.%s' % [layouts_root(), layout_name, ext]
        output = template(engine, file, @action, context).render(scope, context) { output }
      end
      output
    end

  end
end
