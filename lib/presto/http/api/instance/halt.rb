module Presto
  module HTTP
    class InstanceApi

      # stop executing any action/hook and send response to browser.
      # usually first arg is body and second an hash,
      # containing status code and any optional headers.
      # however, if first arg is an array, it is treated as Rack response
      # and second arg is simply ignored.
      #
      # @example returning "Well Done" body with 200 status code:
      #    http.halt 'Well Done'
      # @example returning error with 500 code:
      #    http.halt 'Sorry, some fatal error occurred', status: 500
      # @example custom content type:
      #    http.halt File.read('/path/to/theme.css'), 'Content-Type' => http.mime_type('.css')
      # @example switching to a custom Rack response:
      #    http.halt [200, {'Content-Disposition' => "attachment; filename=some-file"}, some_IO_instance]
      #
      # @param [String, Array] body_or_response
      # @param [Hash] opts
      # @option opts [Integer] :status
      # @option opts any other opts treated as headers
      def halt body_or_response = nil, opts = {}

        if body_or_response.is_a?(Array)
          body_or_response[2] = [] if head? # sending empty body on HEAD requests
          throw :__presto_catch_response__, body_or_response
        end

        # extracting and remove status from opts
        if status = opts.delete(:status) || opts.delete('status')
          @response.status = status.to_i
        end

        # remaining opts are treated as headers
        opts.each_pair { |k, v| @response[k] = v }

        # finishing response by sending first argument as body
        throw :__presto_catch_halt__, body_or_response
      end

      alias :finish :halt
    end
  end
end
