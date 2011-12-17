module Presto
  module HTTP
    class Response

      # set status code, headers and body, honoring authorization status.
      def authenticated?

        # simply return authenticated?=true if no restrictions defined.
        return true unless auth = @node_instance.http.auth

        if auth.pass_validation?
          if headers = auth.post_validation_headers
            @response.headers.update headers
          end
          if status_code = auth.post_validation_status_code
            @response.status = status_code
          end
          return auth.user
        end

        # seems no credentials received from browser
        # or sent ones does not pass validation.
        # sending authorization request.
        @response.status = auth.status_code
        @response.headers.update auth.headers
        @response.body = [auth.body]

        nil
      end

    end
  end
end
