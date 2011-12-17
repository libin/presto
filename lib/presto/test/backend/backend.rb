module Presto
  module Test
    class Backend

      include Presto::InternalUtils

      attr_reader :setup, :opts

      def initialize app, node, action, test

        @app, @node, @action, @opts = app, node, action, test[:opts]
        @setup = Frontend::Setup.new(node, &test[:proc])

      end

      def skip?
        opts[:skip]
      end

      def evaluate_specs

        callback(@setup, :open) unless skip?

        setup.specs.each do |spec|

          evaluator = Frontend.new @app, @node, @setup

          if skip? || spec[:opts][:skip]
            evaluator.context[nil][:skipped?] = true
          else

            callback(evaluator, :before) if before?(spec[:opts])
            
            user, pass = evaluator.auth
            evaluator.browser.authorize(user, pass) if user && pass

            evaluator.instance_exec @action, &spec[:proc]

            callback(evaluator, :after) if after?(spec[:opts])
          end

          [:assertions, :assertions_failed, :context, :output].each do |v|
            spec[v] = evaluator.send(v)
          end

        end
        
        callback(@setup, :close) unless skip?

      end

      private

      def callback instance, callback
        if (callback = setup.send(callback)).is_a?(Proc)
          instance.instance_exec &callback
        end
      end

      # some tests may avoid executing of callbacks.
      # simply set before/after option to false or nil.
      # it is also possible to disable both callbacks at same time,
      # by set :callbacks option tp false.
      def before? opts
        if yes = setup.before
          yes = opts.fetch(:callbacks, nil)
          yes = opts.fetch(:before, yes)
        end
        yes
      end

      def after? opts
        if yes = setup.after
          yes = opts.fetch(:callbacks, nil)
          yes = opts.fetch(:after, yes)
        end
        yes
      end

    end
  end
end
