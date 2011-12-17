module Presto
  module HTTP
    class InstanceApi

      # read / write sessions
      #
      # @example set session
      #    http.session[:page] = 1
      # @example get session
      #    http.session[:page]
      # @example delete session
      #    http.session.delete :page
      def session
        @session__proxy ||= SessionProxy.new @request, @response
      end

      # @example
      #    http.flash[:alert] = 'Item Deleted'
      #    p http.flash[:alert] #=> "Item Deleted"
      #    p http.flash[:alert] #=> nil
      def flash
        api, uniq = self, 'session__flash_proxy-%s' % @node.__id__
        unless @session__flash_proxy
          @session__flash_proxy = Class.new
          @session__flash_proxy.define_singleton_method :[]= do |key, val|
            api.session['%s-%s' %[uniq, key]] = val
          end
          @session__flash_proxy.define_singleton_method :[] do |key|
            api.session.delete '%s-%s' % [uniq, key]
          end
        end
        @session__flash_proxy
      end

      class SessionProxy

        def initialize request, response
          @request, @response = request, response

          opts = Presto.opts.session
          @cookie_name = opts.cookie_name
          @ttl = opts.ttl.to_i
          @pool = opts.pool.db(:presto_session, true)
          @ttl_pool = opts.pool.db(:presto_session_ttl, true)
        end

        # set / update session item
        def []= key, val
          return if confined?
          sid = session_id
          session = @pool[sid] || Hash.new
          session[key.to_s] = val
          return unless @pool[sid] = session
          val
        end

        # get session item by key
        def [] key
          sid = session_id
          return unless session = @pool[sid]
          session[key.to_s]
        end

        # delete session item
        def delete key
          return if confined?
          sid = session_id
          return unless session = @pool[sid]
          val = session.delete(key.to_s)
          return unless @pool[sid] = session
          val
        end

        # purging sessions that was not accessed
        # for a time period longer than session ttl.
        def sweep
          time_now = Time.now.utc
          @ttl_pool.each_pair do |sid, expires_at|
            next if time_now < expires_at
            @pool.delete(sid)
            @ttl_pool.delete(sid)
          end
        end

        # prohibit further session writing
        #
        # @example prohibit writing for all actions
        #    http.before do
        #      http.session.confine
        #    end
        #
        # @example prohibit writing selectively
        #    http.before :render_page do |action|
        #      http.session.confine
        #    end
        def confine
          @confined = true
        end

        def confined?
          @confined
        end

        private
        # session cookie will expire at browser close.
        # session itself expiring when current time + ttl is in the past.
        # but session ttl updated on each session access,
        # so, a session will expire on browser close
        # or in case it is not accessed for a time period longer than session ttl.
        # first case just complementing the second one, cause if browser closed,
        # the session will not be accessed for a time period longer than ttl.
        def session_id
          unless sid = @request.cookies[@cookie_name]
            sid = Digest::MD5.hexdigest('%s::%s' % [Time.now.to_f, rand(2**512)])
            @response.set_cookie @cookie_name, value: sid, path: "/"
          end
          @ttl_pool[sid] = Time.at(Time.now.to_i + @ttl).utc
          sid
        end
      end

    end
  end
end
