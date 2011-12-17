module Presto
  module HTTP
    class InstanceApi

      include Presto::InternalUtils
      include SharedApi

      attr_reader :action, :action_route
      attr_reader :params, :get_params, :post_params
      attr_reader :cache, :user
      attr_reader :sandbox_capabilities
      attr_reader :auth

      # initializing the HTTP Api to be used at instance level.
      #
      # @param node_instance
      # @param action
      # @param response
      # @param user
      def initialize node_instance, env, action, response, user = nil

        # Note! do not set an attr for response,
        # this will allow to bypass sandbox.

        @node, @node_instance = node_instance.class, node_instance
        @action, @action_route = action, @node.node.map[action][:route]
        @response, @user = response, user
        @request = ::Rack::Request.new env

        @params = @request.params
        @get_params = @request.GET
        @post_params = @request.POST

        if restriction = @node.http.auth(@action)
          type = (restriction[:type] || :basic).to_s.capitalize.to_sym
          @auth = Presto::HTTP::Auth.const_get(type).new @node_instance, env, restriction
        end
      end

      def user
        @auth && @auth.user
      end

      [
          :scheme,
          :host,
          :host_with_port,
          :port,
          :script_name,
          :path_info,
          :request_method,
          :query_string,
          :body,
          :content_length,
          :content_type,
          :media_type,
          :content_charset,
          :delete,
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
          :logger,
      ].each do |m|
        define_method m do |*args|
          @request.send(m, *args)
        end
      end

      # simply a wrapper for Presto::Utils.normalize_path that adding current path to args.
      def normalize_path *args
        Presto::Utils.normalize_path @request.path, *args
      end

      def env
        @request.env
      end

    end
  end
end
