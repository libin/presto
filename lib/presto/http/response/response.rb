module Presto
  module HTTP
    class Response

      include Presto::InternalUtils

      def initialize node, action
        @node = node
        @action = action

        @hooks_a = hooks(@node.http.hooks_a)
        @hooks_z = hooks(@node.http.hooks_z)
      end

      def call env

        @env = env
        catch :__presto_catch_response__ do

          @response = ::Rack::Response.new

          @node_instance = @node.new(@env, @action, @response)

          if authenticated?


            if file_server = @node.http.file_server
              if proc = file_server[:proc]
                proc.call(@env)
              end
              root, cache_control = file_server.values_at(:root, :cache_control)
              throw :__presto_catch_response__, ::Rack::File.new(root, cache_control).call(@env)
            end

            @response['Content-Type'] = content_type

            @action_params = params_extracted
            @params_min, @params_max = params_required
            @path_params = params_given @node_instance.http.path_info

            # execute action if path params corresponds to action params
            if params_valid?
              body = yield_action
            else
              # otherwise send "404 NotFound" response
              if error_proc = @node.http.error(STATUS_NOT_FOUND)
                body = @node_instance.instance_exec(@action, &error_proc).to_s
              else
                body = not_found_error
              end
              @response.status = STATUS_NOT_FOUND

            end
            @response.body = [body]

          end

          @response.body = [] if @env['REQUEST_METHOD'] == 'HEAD'
          @response.finish
        end
      end

      private
      # checking for custom content type for current action and returns defaults if none found.
      # defaults are looked at partition level then at Presto.opts
      #
      # @return [String]
      def content_type
        action_content_type = nil
        if proc = @node.http.content_type(@action)
          action_content_type = @node_instance.instance_exec(@action, &proc)
        end
        action_content_type || Presto.opts.content_type
      end

      # default html body for not found error.
      # used if no custom error handler found for current action.
      #
      # @return [String]
      def not_found_error
        " <h3>Not Found: 404</h3>
        <hr/>
        Node: %s
        <br/>
        Action: %s
        <br/>
        Route: %s
        <br/>
        Args: %s
      " % [
            @node, @action, @node_instance.http.route(@action), @path_params.join(', ')
        ].map { |s| '<code>%s</code>' % s }
      end

    end
  end
end
