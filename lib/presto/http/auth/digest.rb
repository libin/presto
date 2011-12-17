module Presto
  module HTTP
    module Auth
      class Digest

        include Presto::InternalUtils

        TYPE = :digest.freeze
        QOP = 'auth'.freeze
        attr_reader :user

        class Nonce
          class << self
            def new
              digest = ::Digest::MD5.hexdigest [Time.now.to_f, rand(2**1024)] * ':'
              [([Time.now.utc.to_i, digest] * ' ')].pack("m*").strip
            end

            def age nonce
              timestamp = nonce.unpack("m*").first.split(' ', 2).first.to_i
              Time.now.to_i - timestamp
            end
          end
        end

        def initialize node_instance, env, setup = {}
          @node_instance = node_instance
          @env, @setup = env.dup, setup.dup
          @realm = @setup[:realm] || 'Access Restricted'
        end

        def stale?
          @stale
        end

        def provided?
          AUTHORIZATION_KEYS.detect { |key| @env.has_key?(key) }
        end

        def pass_validation?

          return unless key = provided?
          @params = split_header(@env[key]).inject(Hash.new) do |params, param|
            k, v = param.split('=', 2)
            params.update k => dequote(v)
          end
          @nonce = @params['nonce'] || Nonce.new
          if (ttl = @setup[:nonce_ttl]) && Nonce.age(@nonce) > ttl
            @nonce = Nonce.new
            @stale = true
          end

          password = @node_instance.instance_exec(@params['username'], &@setup[:proc])
          password = md5(a1(password)) if @setup[:plain]

          digest = [*@params.values_at(*%w[nonce nc cnonce qop]), md5(a2)] * ':'
          valid_response = md5([password, digest] * ':')
          if valid_response == @params['response']
            @user = @params['username']
          end
          user
        end

        def headers opts = {}
          params = [
              'realm="%s"' % @realm,
              'qop="%s"' % QOP,
              'nonce="%s"' % nonce,
              'opaque="%s"' % opaque,
          ]
          params << 'stale="true"' if opts[:stale]
          {
              'Content-Type' => CONTENT_TYPE_PLAIN,
              'WWW-Authenticate' => 'Digest %s' % params.join(',')
          }
        end

        def body
          @setup[:body] || 'Access Restricted'
        end

        def status_code
          STATUS_RESTRICTED
        end

        def post_validation_headers
          stale? ? headers(stale: true) : nil
        end

        def post_validation_status_code
          stale? ? status_code : nil
        end

        private
        def dequote(str) # From WEBrick::HTTPUtils
          ret = (/\A"(.*)"\Z/ =~ str) ? $1 : str.dup
          ret.gsub!(/\\(.)/, "\\1")
          ret
        end

        def split_header header # from Rack::Auth::Digest::Params
          header.scan(/(\w+\=(?:"[^\"]+"|[^,]+))/n).collect { |v| v[0] }
        end

        def nonce
          @nonce ||= Nonce.new
        end

        def opaque
          @opaque ||= md5 [Time.now.to_f, nonce] * ':'
        end

        def a1 password
          [@params['username'], @realm, password] * ':'
        end

        def a2
          [@env['REQUEST_METHOD'], @params['uri']] * ':'
        end

        def md5 str
          ::Digest::MD5.hexdigest str
        end

      end
    end
  end
end
