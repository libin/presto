module Presto
  module Test

    class << self

      include Utils

      def run app, opted = {}

        @opts = {verbose: true}.update(opted)
        @tests = Hash.new
        @specs_total, @specs_failed, @specs_skipped = 0, 0, Hash.new
        @assertions_total, @assertions_failed = 0, Hash.new
        @output = Array.new

        Presto.nodes.reject { |n| n.node.tests.nil? || n.node.map.nil? }.each do |node|

          @tests[node] = Hash.new

          node.node.tests.each_pair do |action, action_tests|

            @tests[node][action] = Array.new

            action_tests.each do |test_setup|

              test = Presto::Test::Backend.new(app, node, action, test_setup)
              @tests[node][action] << test

              test.evaluate_specs

              test.setup.specs.each do |spec|

                next unless spec_context = spec[:context]
                unless action_map = node.node.map[action]
                  p node.node.map
                  raise "#{node} wrongly mapped? Can not find route for ##{action}"
                end
                spec_action = node.to_s + "#" + action.to_s + " - #{action_map[:route]}"
                spec_context.each_pair do |key, context|

                  if context[:skipped?]
                    @specs_skipped[spec_action] ||= Array.new
                    @specs_skipped[spec_action] << [spec, context]
                    next
                  end

                  @specs_total += 1
                  @assertions_total += spec[:assertions][key].to_i
                  if (failed = spec[:assertions_failed][key]) && failed.size > 0

                    @output << 'F'
                    @specs_failed += 1
                    @assertions_failed[spec_action] ||= Hash.new
                    @assertions_failed[spec_action][spec[:goal]] ||= Hash.new
                    @assertions_failed[spec_action][spec[:goal]][context[:goal]] ||= Array.new

                    debug = [].concat(failed)
                    if (context_output = spec[:output][key]) && context_output.size > 0
                      debug << ''
                      debug << blue("Goal: ")
                      debug << "should #{spec[:goal]} #{context[:goal]}"
                      debug << blue('Details:')
                      debug.concat(context_output)
                    end
                    @assertions_failed[spec_action][spec[:goal]][context[:goal]].concat(debug)

                  else
                    @output << '.'
                  end

                end
              end
            end
          end
        end
        output
        failed_assertions
        skipped_specs
        totals
      end

      def output

        puts
        @output.each { |s| print s.to_s }
        puts

        return unless @opts[:verbose]
        puts

        prefix, prefix_n = ' ', 0
        @tests.each_pair do |node, node_tests|
          node_tests.each_pair do |action, action_tests|

            puts blue (prefix*prefix_n) + node.to_s + "#" + action.to_s + " - #{node.node.map[action][:route]} - #{action_tests.size} tests"
            puts

            action_tests.each do |test|

              prefix_n += 4
              if label = test.setup.label
                puts (prefix*(prefix_n-2)) + label
                puts
              end

              if test.skip?
                puts blue (prefix*prefix_n) + 'Skipped'
                puts
              else

                test.setup.specs.each do |spec|

                  prefix_n += 2

                  puts magenta (prefix*(prefix_n-2)) + "should " + spec[:goal].to_s + " ..."

                  if spec_context = spec[:context]
                    spec_context.each_pair do |key, context|

                      context_level = context[:level]

                      prefix_n += 2*context_level
                      if goal = context[:goal]
                        puts
                        puts magenta((prefix*(prefix_n-2)) + 'should ' + goal)
                      end

                      if context[:skipped?]
                        puts (prefix*prefix_n) + blue('Skipped')
                      else
                        if context_output = spec[:output][key]
                          context_output.each do |str|
                            puts (prefix*prefix_n) + str
                          end
                        end
                        if context[:failed?]
                          puts (prefix*prefix_n) + red('Skipped due to previous error')
                        end
                      end
                      prefix_n -= 2*context_level
                    end
                  end

                  puts
                  prefix_n -= 2
                end
              end
              prefix_n -= 4
            end
          end
        end
      end

      def failed_assertions

        if @assertions_failed.size > 0

          puts
          puts red "--- Failed Assertions ---"
          puts

          prefix, prefix_n = ' ', 0
          @assertions_failed.each_pair do |action, specs|

            puts blue (prefix*prefix_n) + action
            puts
            prefix_n += 2
            specs.each_pair do |spec_goal, spec_context|
              puts magenta (prefix*prefix_n) + 'should ' + spec_goal
              prefix_n += 2
              spec_context.each_pair do |context, errors|
                puts magenta (prefix*prefix_n) + 'should ' + context if context
                prefix_n += 2 if context
                errors.each do |error|
                  puts '%s %s' % [(prefix*prefix_n), error]
                end
                puts
                prefix_n -= 2 if context
              end
              prefix_n -= 2
            end
            prefix_n -= 2
          end
        end
      end

      def skipped_specs

        if @specs_skipped.size > 0

          puts
          puts blue "--- Skipped Specs ---"
          puts

          prefix, prefix_n = ' ', 0
          @specs_skipped.each_pair do |action, specs|

            puts blue (prefix*prefix_n) + action
            prefix_n += 2
            specs.each do |spec_and_context|
              spec, context = spec_and_context
              spec_goal = context[:goal] || spec[:goal]
              prefix_n += 2*context[:level]
              puts magenta (prefix*prefix_n) + 'should ' + spec_goal + ' at ' + spec[:proc].to_s
              prefix_n -= 2*context[:level]
            end
            prefix_n -= 2
          end
        end
        puts
      end

      def totals

        puts '---'
        puts "assertions:         " + @assertions_total.to_s
        puts "           passed:  " + (@assertions_total - @assertions_failed.size).to_s
        puts "           failed:  " + @assertions_failed.size.to_s
        puts
        puts "specs:             " + @specs_total.to_s
        puts "      passed:      " + (specs_passed = @specs_total - @specs_failed).to_s
        puts "      failed:      " + @specs_failed.to_s
        specs_skipped = 0
        @specs_skipped.keys.map { |k| specs_skipped += @specs_skipped[k].size }
        puts magenta("      skipped:    ~" + specs_skipped.to_s + " (nested specs not counted)") if specs_skipped > 0
        puts
        passing_rate = (specs_passed.to_f / @specs_total.to_f) * 100.0
        passing_rate_color = :red
        passing_rate_color = :magenta if (80..100).include?(passing_rate)
        passing_rate_color = :green if passing_rate == 100
        puts self.send passing_rate_color, "Passing Rate: #{ '%.2f' % passing_rate }%"
        puts
      end
    end
  end
end
