module Presto
  module HTTP
    class InstanceApi

      # limit access to HTTP Api.
      # by default it will allow to read params, host, port etc.
      # however it wont allow reading session/cookies/env
      # neither will allow redirects, forwarding or halt.
      # to allow additional capabilities, add them as arguments.
      #
      # @example generic sandbox for all actions
      #    http.before do
      #      http.confine
      #    end
      #
      # @example generic sandbox for #render action
      #    http.before :render do
      #      http.confine
      #    end
      #
      # @example sandbox with redirect capability for all actions
      #    http.before do
      #      http.confine :redirect
      #    end
      #
      # @example sandbox with session and cookies capability for #order action
      #    http.before :order do
      #      http.confine :session, :cookies
      #    end
      #
      # @param [Array] capabilities
      def confine *capabilities
        @sandbox_capabilities = capabilities
      end

      # creating a sandbox.
      #
      # @example using a confined api to render an untrusted view
      #    def content
      #      api = http.sandbox
      #      view.render_view '/path/to/file', http: api
      #    end
      #
      # @param [Array] capabilities
      def sandbox *capabilities
        [
            :flash,
            :user,
            :params,
            :scheme,
            :host,
            :host_with_port,
            :port,
            :path_info,
            :request_method,
            :query_string,
            :body,
            :content_length,
            :content_type,
            :media_type,
            :content_charset,
            :get?,
            :head?,
            :options?,
            :post?,
            :put?,
            :xhr?,
            :trace?,
            :form_data?,
            :parseable_data?,
            :referer,
            :referrer,
            :user_agent,
            :url,
            :path,
            :fullpath,
            :accept_encoding,
            :ip,
        ].each do |capability|
          capabilities << capability
        end
        api, sandbox = self, Class.new
        capabilities.uniq.each do |capability|
          sandbox.define_singleton_method capability do |*args|
            api.send capability, *args
          end
        end
        sandbox
      end

    end
  end
end
