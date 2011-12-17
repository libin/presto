module Presto
  class Browser

    attr_accessor :request_method, :xhr

    def initialize node, request_method = 'GET', xhr = false
      @node, @request_method, @xhr = node, request_method, xhr
    end

    # simple tool to perform internal HTTP requests.
    # it does not support authorization,
    # so browsing an action that requires authorization
    # will return an "Access Restricted" body.
    # @example
    #    class App
    #      include Presto::Api
    #      http.map
    #      def action arg
    #      end
    #    end
    #    # now you can use http.get(:action, 'someVal') from inside App class
    #    # and App.http.get(:action, 'someVal') from outside App class.
    #    # As it is an HTTP request, it will respect auth set by called node.
    #
    # @param [Array] args
    # @param [Hash, Symbol] params_or_action
    # @return [String]
    def request *args, params_or_action

      # path_info consist of passed arguments,
      # except first one of course, as it is name of executed action.
      # path_info ever starts with an slash.
      path_info = "/"

      query_string = ""

      if args.size > 0

        action = args.delete_at(0)
        path_info << args.map { |a| ::Rack::Utils.escape_path(a) }.join("/")

        if params_or_action.is_a?(Hash)

          query_string = ::Rack::Utils.build_nested_query(params_or_action)

        else

          # simply adding last argument to path info
          path_info << "/" << params_or_action.to_s
        end

      else

        # an single argument passed, so assuming it is the action name
        action = params_or_action
      end

      env = {
          'rack.version' => ::Rack::VERSION,
          'rack.input' => StringIO.new(query_string),
          'rack.multithread' => true,
          'rack.multiprocess' => true,
          'rack.run_once' => false,
          'rack.url_scheme' => 'http',
          'HTTPS' => 'off',
          'REQUEST_METHOD' => @request_method,
          'PATH_INFO' => path_info,
          'QUERY_STRING' => query_string,
      }
      env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded' if post?
      env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest' if xhr?
      Presto::HTTP::Response.new(@node, action).call(env)
    end

    # wrapper around #request.
    # it accepts same args as request and return the body returned by #request
    #
    # @return [String]
    def body *args, params_or_action
      request(*args, params_or_action)[2].body.join
    end

    private
    def get?
      @request_method == "GET"
    end

    def post?
      @request_method == "POST"
    end

    def xhr?
      @xhr
    end

  end
end
