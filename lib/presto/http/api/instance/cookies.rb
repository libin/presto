module Presto
  module HTTP
    class InstanceApi

      # get / set cookies
      def cookies
        @cookies__proxy ||= CookiesProxy.new @request, @response
      end

      class CookiesProxy

        def initialize request, response
          @request, @response = request, response
        end

        # instruct browser to set/update cookie
        #
        # @param [String, Symbol] key
        # @param [String] val
        # @return [Boolean]
        def []= key, val
          return if confined?
          @response.set_cookie key, val
        end

        # get cookie by key
        def [] key
          @request.cookies[key]
        end

        # instruct browser to delete a cookie
        #
        # @param [String, Symbol] key
        # @param [Hash] opts
        # @return [Boolean]
        def delete key, opts ={}
          return if confined?
          @response.delete_cookie key, opts
        end

        # prohibit further cookies writing
        #
        # @example prohibit writing for all actions
        #    http.before do
        #      http.cookies.confine
        #    end
        #
        # @example prohibit writing selectively
        #    http.before :render_page do |action|
        #      http.cookies.confine
        #    end
        def confine
          @confined = true
        end

        def confined?
          @confined
        end

      end

    end
  end
end
