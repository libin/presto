module Presto
  module Test
    class Frontend
      module Request

        include Utils
        include Assertions

        def request opts = {}

          return @__presto_test_evaluator_mock_browser__.get('/') if @__presto_test_evaluator_spec_failed__

          method = (opts[:method] || 'get').to_s.strip.downcase
          node = @__presto_test_evaluator_node__
          if opts[:args].first.respond_to?(:http)
            node = opts[:args].delete_at(0)
          end
          args, params = Array.new, Hash.new
          opts[:args].each { |a| a.is_a?(Hash) ? params.update(a) : args << a }
          args = [:index] if args.size == 0
          url = node.http.route *args

          @__presto_test_evaluator_output__[@__presto_test_evaluator_context_id__] ||= Array.new
          output = "#{ 'XHR ' if opts[:xhr]}#{method.upcase}: #{node.http.route(*args)}"
          @__presto_test_evaluator_output__[@__presto_test_evaluator_context_id__] << output

          rsp = @__presto_test_evaluator_browser__.send(method, url, params)
          return rsp unless opts[:json]
          [rsp, (::JSON.parse(rsp.body) rescue Hash.new)]
        end

        def get *args
          request args: args
        end

        def get_json *args
          request args: args, json: true
        end

        def post *args
          request args: args, method: "POST"
        end

        def post_json *args
          request args: args, method: "POST", json: true
        end

        def xhr_get *args
          request args: args, xhr: true
        end

        def xhr_get_json *args
          request args: args, xhr: true, json: true
        end

        alias :xhr :xhr_get
        alias :xhr_json :xhr_get_json

        def xhr_post *args
          request args: args, method: "POST", xhr: true
        end

        def xhr_post_json *args
          request args: args, method: "POST", xhr: true, json: true
        end

      end
    end
  end
end
