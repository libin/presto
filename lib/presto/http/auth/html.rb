module Presto
  module HTTP
    module Auth
      class Html

        include Presto::InternalUtils

        TYPE = :html.freeze

        attr_reader :user

        def initialize node_instance, env, setup = {}
          @node_instance = node_instance
          @env, @setup = env.dup, setup.dup

          @key_field = setup[:key] || 'presto-authorization-html'
          @username_field = setup[:username] || 'username'
          @password_field = setup[:password] || 'password'

          @params = ::Rack::Request.new(@env).POST
        end

        def provided?
          @params[@key_field]
        end

        def pass_validation?
          @user = @node_instance.instance_exec(*credentials, &@setup[:proc])
        end

        def headers
          {
              'Content-Type' => CONTENT_TYPE_HTML,
          }
        end

        def status_code
          STATUS_OK
        end

        def post_validation_headers
          provided? ? {'Location' => @env['REQUEST_URI']} : nil
        end

        def post_validation_status_code
          provided? ? STATUS_REDIRECT : nil
        end

        def body
          @setup[:body] || <<-HTML
        <form action="" method="POST" id="presto-authorization-html-form">
          <input type="text" name="username" id="presto-authorization-html-username">
          <input type="password" name="password" id="presto-authorization-html-password">
          <input type="submit" name="presto-authorization-html" id="presto-authorization-html" value="Authenticate">
        </form>
          HTML
        end

        private
        def credentials
          [@params[@username_field], @params[@password_field]]
        end
      end
    end
  end
end
