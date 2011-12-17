module Presto
  module HTTP
    module Auth
      class Basic

        include Presto::InternalUtils

        TYPE = :basic.freeze

        attr_reader :user

        def initialize node_instance, env, setup = {}
          @node_instance = node_instance
          @env, @setup = env.dup, setup.dup
          @realm = @setup[:realm] || 'Access Restricted'
        end

        def provided?
          AUTHORIZATION_KEYS.detect { |key| @env.has_key?(key) }
        end

        def pass_validation?
          return unless key = provided?
          return unless credentials = extract_credentials(key)
          if @node_instance.instance_exec(*credentials, &@setup[:proc])
            @user = credentials.first
          end
          user
        end

        def headers
          {
              'Content-Type' => CONTENT_TYPE_PLAIN,
              'WWW-Authenticate' => 'Basic realm="%s"' % @realm,
          }
        end

        def status_code
          STATUS_RESTRICTED
        end

        def body
          @setup[:body] || 'Access Restricted'
        end

        def post_validation_headers
          nil
        end

        def post_validation_status_code
          nil
        end

        private
        def extract_credentials key
          @env[key].split(' ', 2).last.unpack("m*").first.split(/:/, 2) rescue nil
        end

      end
    end
  end
end
