module Presto
  module Test
    class Frontend
      class Setup

        include NodeAssessor

        def initialize node, &proc
          @__presto_test_setup_node__ = node
          @__presto_test_setup_specs__ = Array.new
          self.instance_exec &proc
        end

        def specs
          @__presto_test_setup_specs__
        end

        def label label = nil
          @__presto_test_setup_label__ = label if label
          @__presto_test_setup_label__
        end

        def open &proc
          @__presto_test_setup_open__ = proc if proc
          @__presto_test_setup_open__
        end

        def close &proc
          @__presto_test_setup_close__ = proc if proc
          @__presto_test_setup_close__
        end

        def before &proc
          @__presto_test_setup_before__ = proc if proc
          @__presto_test_setup_before__
        end

        def after &proc
          @__presto_test_setup_after__ = proc if proc
          @__presto_test_setup_after__
        end

        def should goal, opts = {}, &proc
          @__presto_test_setup_specs__ << {
              goal: goal,
              opts: opts,
              proc: proc
          }
        end

        def node
          @__presto_test_setup_node__
        end

      end
    end
  end
end
