module Presto
  module Test
    class Frontend

      include Presto::InternalUtils
      include NodeAssessor
      include Assertions
      include Request

      def initialize app, node, setup_instance

        @__presto_test_evaluator_node__ = node

        @__presto_test_evaluator_browser__ = ::Rack::Test::Session.new(app)
        @__presto_test_evaluator_mock_browser__ = ::Rack::Test::Session.new(lambda { |*a| [200, {}, []] })

        @__presto_test_evaluator_output__ = Hash.new
        @__presto_test_evaluator_assertions__ = Hash.new
        @__presto_test_evaluator_assertions_failed__ = Hash.new
        @__presto_test_evaluator_context__ = {nil => {level: 0}}
        @__presto_test_evaluator_context_id__ = nil
        @__presto_test_evaluator_context_level__ = 0
        @__presto_test_evaluator_spec_failed__ = nil
        @__presto_test_evaluator_auth__ = nil

        setup_instance.instance_variables.reject { |v| v =~ /__presto_test_/ }.each do |v|
          self.instance_variable_set v, setup_instance.instance_variable_get(v)
        end
      end

      def auth user = nil, pass = nil
        @__presto_test_evaluator_auth__ = user, pass if user && pass
        @__presto_test_evaluator_auth__
      end

      def auth_unset
        @__presto_test_evaluator_auth__ = nil
      end

      def output output = nil
        return @__presto_test_evaluator_output__ unless output
        @__presto_test_evaluator_output__[@__presto_test_evaluator_context_id__] ||= Array.new
        @__presto_test_evaluator_output__[@__presto_test_evaluator_context_id__] << output
      end

      def should goal, opts = {}, &proc

        @__presto_test_evaluator_context_level__ += 1
        context_id_was = @__presto_test_evaluator_context_id__
        @__presto_test_evaluator_context_id__ = goal.__id__

        @__presto_test_evaluator_assertions_failed__[@__presto_test_evaluator_context_id__] ||= Array.new
        @__presto_test_evaluator_context__[@__presto_test_evaluator_context_id__] = {
            :goal => goal,
            :level => @__presto_test_evaluator_context_level__,
            :failed? => @__presto_test_evaluator_spec_failed__,
            :skipped? => opts[:skip],
        }

        proc.call unless opts[:skip]

        @__presto_test_evaluator_context_level__ -= 1
        @__presto_test_evaluator_context_id__ = context_id_was
      end

      def node
        @__presto_test_evaluator_node__
      end

      def assertions
        @__presto_test_evaluator_assertions__
      end

      def assertions_failed
        @__presto_test_evaluator_assertions_failed__
      end

      def context
        @__presto_test_evaluator_context__
      end

    end
  end
end
