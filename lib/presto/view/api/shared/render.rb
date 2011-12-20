module Presto
  module View
    module SharedApi

      # render a view without layout
      #
      # if path is an symbol, and there are an node method with same name,
      # path is taken from { method => [paths] } map.
      #
      # if first argument is nil, current action will be rendered.
      #
      # if absolute path given, given file will be rendered.
      #
      # a custom scope can be passed as first argument.
      # if any argument is a Hash, it will be used as context.
      #
      # if no extension found in path, it will be searched in node setup,
      # or guessed by engine when engine given explicitly.
      #
      # @param [Symbol, String, nil] path_or_action
      # @param [Object, Hash, nil] *scope_and_or_context
      # @return [String]
      def render_view path_or_action = nil, *scope_and_or_context

        file = guess_path path_or_action || @action, ext() || guess_extension(engine())
        scope, context = guess_scope_and_context *scope_and_or_context

        template(engine(), file, @action, context).render(scope, context)
      end

      alias :render_partial :render_view

      # render current layout
      # first argument to be yielded as layout content.
      #
      # @param [String, nil] output
      # @param [Object, Hash, nil] *scope_and_or_context
      # @return [String]
      def render_layout output = nil, *scope_and_or_context
        if file = guess_layout
          scope, context = guess_scope_and_context *scope_and_or_context
          output = template(engine, file, @action, context).render(scope, context) { output.to_s }
        end
        output
      end

      ENGINES.each_pair do |label, engine|

        # same as #render_view except it defines engine explicitly
        define_method :"render_#{label.downcase}_view" do |path_or_action = nil, *scope_and_or_context|
          file = guess_path path_or_action || @action, guess_extension(engine)
          scope, context = guess_scope_and_context *scope_and_or_context
          template(engine, file, @action, context).render(scope, context)
        end

        alias :"render_#{label.downcase}_partial" :"render_#{label.downcase}_view"

        # same as #render_layout except it defines engine explicitly
        define_method :"render_#{label.downcase}_layout" do |output = nil, *scope_and_or_context|
          if file = guess_layout(guess_extension(engine))
            scope, context = guess_scope_and_context *scope_and_or_context
            output = template(engine, file, @action, context).render(scope, context) { output.to_s }
          end
          output
        end

      end

    end
  end
end
