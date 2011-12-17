module Presto
  module Test
    class Frontend
      module Assertions

        include Utils

        # TODO: add more assertions

        def assert assertion, actual, expected = nil, message = nil, opts = {}

          return if @__presto_test_evaluator_spec_failed__

          unless opts[:proxy]
            # checking if given value is proxied
            actual = actual.val if actual.val rescue nil
          end
          tst, msg = nil, nil

          case assertion
            when :equal, :eql, :==
              tst = lambda { expected == actual }
              msg = message || "Expected #{actual_format(actual)} to :{:refute?:}: be equal to #{expected.inspect}"

            when :match, :=~
              tst = lambda { expected.match actual }
              msg = message || "Expected #{actual_format(actual)} to :{:refute?:}: match #{expected.inspect}"

            when :respond_to, :respond_to?
              tst = lambda { actual.respond_to?(expected) }
              msg = message || "Expected #{actual} to :{:refute?:}: respond to #{expected}"

            when :gt, :>
              tst = lambda { actual > expected }
              msg = message || "Expected page #{actual} to :{:refute?:}: be greater than #{expected}"

            when :gte, :>=
              tst = lambda { actual >= expected }
              msg = message || "Expected page #{actual} to :{:refute?:}: be greater or equal than #{expected}"

            when :lt, :<
              tst = lambda { actual < expected }
              msg = message || "Expected page #{actual} to :{:refute?:}: be less than #{expected}"

            when :lte, :<=
              tst = lambda { actual <= expected }
              msg = message || "Expected page #{actual} to :{:refute?:}: be less than or equal to #{expected}"

            when :instance_of, :instance_of?
              tst = lambda { actual.instance_of?(expected) }
              msg = message || "#{actual_format(actual)} should :{:refute?:}: be a instance of #{expected}"

            when :is_a, :is_a?
              tst = lambda { actual.is_a?(expected) }
              msg = message || "#{actual_format(actual)} should :{:refute?:}: be a #{expected}"

            when :nil, :nil?
              tst = lambda { actual.nil? }
              msg = message || "Expected #{actual} :{:refute?:}: to be nil"

          end
          unless tst
            raise '"%s" assertion not found' % assertion
          end
          msg = msg.to_s.gsub(':{:refute?:}:', opts[:refute?] ? magenta(' NOT ') : '')
          msg << blue(" at #{caller[opts[:caller] || 1]}")
          persist(opts[:refute?] ? !tst.call : tst.call, msg)
        end

        def refute assertion, actual, expected = nil, message = nil
          self.assert(assertion, actual, expected, message, caller: 2, :refute? => true)
        end

        private
        def persist test, message

          @__presto_test_evaluator_assertions__[@__presto_test_evaluator_context_id__] ||= 0
          @__presto_test_evaluator_assertions__[@__presto_test_evaluator_context_id__] += 1

          @__presto_test_evaluator_assertions_failed__[@__presto_test_evaluator_context_id__] ||= Array.new
          @__presto_test_evaluator_output__[@__presto_test_evaluator_context_id__] ||= Array.new

          output = @__presto_test_evaluator_assertions__[@__presto_test_evaluator_context_id__].to_s + ": "
          if test
            output << green('ok')
          else
            @__presto_test_evaluator_spec_failed__ = true
            output << red('failed')
            @__presto_test_evaluator_assertions_failed__[@__presto_test_evaluator_context_id__] << message
          end
          @__presto_test_evaluator_output__[@__presto_test_evaluator_context_id__] << output
        end

        def actual_format value
          value.is_a?(String) ? value : value.inspect
        end

      end
    end
  end
end
