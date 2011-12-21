module Presto
  module Test
    class Frontend
      module Assertions

        include Utils

        def test msg = nil, &proc

          return if @__presto_test_evaluator_spec_failed__

          @__presto_test_evaluator_assertions__[@__presto_test_evaluator_context_id__] ||= 0
          @__presto_test_evaluator_assertions__[@__presto_test_evaluator_context_id__] += 1

          @__presto_test_evaluator_assertions_failed__[@__presto_test_evaluator_context_id__] ||= Array.new
          @__presto_test_evaluator_output__[@__presto_test_evaluator_context_id__] ||= Array.new

          output = @__presto_test_evaluator_assertions__[@__presto_test_evaluator_context_id__].to_s + ": "

          if result = proc.call
            output << green('ok')
          else
            @__presto_test_evaluator_spec_failed__ = true
            output << red('failed')
            @__presto_test_evaluator_assertions_failed__[@__presto_test_evaluator_context_id__] << blue("#{msg} at #{proc}")
          end
          @__presto_test_evaluator_output__[@__presto_test_evaluator_context_id__] << output
          result
        end

        alias :t :test

      end
    end
  end
end
