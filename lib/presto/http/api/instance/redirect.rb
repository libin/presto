module Presto
  module HTTP
    class InstanceApi

      # simply reload the page, using current GET params.
      # to use custom GET params, pass a hash as first argument.
      #
      # @param [Hash, nil] params
      def reload params = nil
        redirect build_path(normalize_path(@request.path), params || @get_params)
      end

      # stop any action/hook and redirect right away.
      #
      # @param [String] path
      # @param [Integer, nil] status
      def redirect path, status = nil
        delayed_redirect path, status
        halt
      end

      # ensure the browser will be redirected after action/hook finished.
      #
      # @param (see #redirect)
      # @param (see #redirect)
      def delayed_redirect target, status = nil
        @response.redirect *[target, status].compact
      end

      alias :deferred_redirect :delayed_redirect

    end
  end
end
