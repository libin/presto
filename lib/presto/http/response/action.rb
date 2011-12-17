module Presto
  module HTTP
    class Response

      # wraps action execution into catch procs,
      # so it would be easy to halt response by http.halt.
      # also this method handles raised exceptions.
      #
      # @return [String]
      def yield_action
        begin
          # catch halts from inside actions and hooks
          catch :__presto_catch_halt__ do

            hook_args = [@action].concat(@path_params)

            # Important! hooks executed regardless cache.
            # hooks first argument is current action.
            # other passed arguments are action's params.
            @hooks_a.each { |hook| @node_instance.instance_exec(*hook_args, &hook) }

            body = yield_action_body

            @hooks_z.each { |hook| @node_instance.instance_exec(*hook_args, &hook) }

            body
          end
        rescue => e

          @response.status = STATUS_SERVER_ERROR

          # check for custom error handling procs
          if error_proc = @node.http.error(STATUS_SERVER_ERROR) ||
              @node.node.partition.http.error(STATUS_SERVER_ERROR)
            @node_instance.instance_exec(@action, e, &error_proc).to_s
          else
            # no custom error handling defined,
            # returning error respecting DEBUG level.
            case Presto.opts.debug
              when ::Presto::DEBUG_ENABLED
                raise e
              when ::Presto::DEBUG_LIMITED
                e.to_s
              when ::Presto::DEBUG_DISABLED
                "Server Error Occurred"
            end
          end
        end
      end

      # execute action honoring cache strategy.
      #
      # @return [String]
      def yield_action_body

        proc = @node.http.cache(@action)
        return exec_action unless proc &&
            instruction = @node_instance.instance_exec(@action, *@path_params, &proc)

        # building cache key from current action route and its arguments, passed by HTTP.
        # each action may have multiple cached versions, depending on arguments:
        # consider:
        #    http.cache(:content) { true }
        #    def content page, layout = 'default'
        #    end
        # now, any of links above will have own cache:
        #    /content/
        #    /content/1
        #    /content/1/summary
        cache_uniq = [@node_instance.http.action_route, *@path_params].join('/')
        cache_pool = @node.http.cache_pool

        # got instruction to update cache.
        cache_pool[cache_uniq] = exec_action if instruction == :update
        # returning cache
        cache_pool[cache_uniq] ||= exec_action
      end

      # executing action binded to current path
      #
      # @return [String]
      def exec_action

        if sandbox_capabilities = @node_instance.http.sandbox_capabilities
          # replace HTTP Api with a confined version
          @node_instance.http @node_instance.http.sandbox(*sandbox_capabilities)
        end
        @node_instance.send(@action, *@path_params)
      end

    end
  end
end
