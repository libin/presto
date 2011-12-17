module Presto
  module HTTP

    # @note
    #   configs here are set by both node and partition
    #
    # @note
    #   methods here used to setup the HTTP Api.
    #   to have an consistent setup, it should be write-able only at class definition.
    #   any later updates should be prohibited.
    #   to accomplish this, any updates for mounted nodes are silently dropped.
    module Config

      include Presto::Utils

      attr_reader :middleware

      def initialize *args
        @cache = Hash.new
        @middleware = Array.new
        @restrictions = Hash.new
        @content_type = Hash.new
        @error_procs = Hash.new
        @setup = Hash.new
      end

      # define callbacks to be executed on HTTP errors.
      # @example handle 404 errors:
      #    http.error 404 do |action|
      #      'Page not found. Requested action:' % http.escape_html(action)
      #    end
      #
      # @example handle 500 errors:
      #    http.error 500 do |action, exception|
      #      'Fatal error occurred: ' % exception.to_s
      #    end
      #
      # @param [Integer] code
      # @param [Proc] proc
      def error code, &proc
        if proc && configurable? # prohibit updates after node mounted
          @error_procs[code] = proc
        end
        @setup['%s::%s' % [:error_procs, code]] ||= @error_procs[code] ||
            (@node.node.partition.http.error(code) if @node)
      end

      # content type to be returned by action(s). default is text/html
      # @example
      #    http.content_type { |action| http.mime_type( ".js" ) }
      #    # all actions will return text/javascript
      #
      #    http.content_type :feed { |a| http.mime_type( ".rss" ) }
      #    # feed will return application/rss+xml
      #
      # @attribute content_type
      # @param [Array] actions
      # @param [Proc] proc
      # @return [String]
      def content_type *actions, &proc

        if proc && configurable?
          actions = ['*'] if actions.size == 0
          actions.each { |a| @content_type[a] = proc }
        end

        action = actions.first
        @setup['%s::%s' % [:content_type, action]] ||= @content_type[action] ||
            @content_type['*'] ||
            (@node.node.partition.http.content_type(action) if @node)
      end

      alias :provide :content_type

      # allow app to define its own rewriting rules for method names.
      # each method are translated into its path representation.
      #
      # @note
      #   # default rules
      #    - "__"   (2 underscores) => "-" (dash)
      #    - "___"  (3 underscores) => "/" (slash)
      #    - "____" (4 underscores) => "." (period)
      #
      # @example define custom rules
      #    http.path_rules  "__" => "/",
      #                     "__dash__" => "-",
      #                     "__dot__" => "."
      #
      #    def some__dash__action__dot__html
      #      # will resolve to /some-action.html
      #    end
      #
      # @attribute path_rules
      # @param [Hash] rules
      # return [Hash, nil]
      def path_rules rules = nil
        @path_rules = rules.freeze if rules && configurable?
        @setup[:path_rules] ||= @path_rules ||
            (@node.node.partition.http.path_rules if @node) ||
            Presto.opts.path_rules
      end

      # making some actions, or all, to require authorization.
      #
      # @example restricting all actions:
      #    http.auth do |user, pass|
      #      # some validation logic
      #    end
      # @example restricting only #edit action:
      #    http.auth :edit do |u,p|
      #    end
      # @example restricting only #edit and #delete actions:
      #    http.auth :edit, :delete do |u,p|
      #    end
      # @example digest auth:
      #    realm = 'AccessRestricted'
      #    http.auth type: :digest, realm: realm  do |user|
      #      # hash the password somewhere in irb:
      #      # ::Digest::MD5.hexdigest ['user', realm, 'somePassword'] * ':'
      #      # the hash used below is obtained from:
      #      # ::Digest::MD5.hexdigest ['admin', realm, 'pwd'] * ':'
      #      {
      #          'admin' => '9d77d54decc22cdcfb670b7b79ee0ef0'
      #      }[user]
      #    end
      # @example plain password
      #    http.auth type: :digest, plain: true  do |user|
      #      # Note! it is strongly discouraged to put here plain text password.
      #      # use :plain only if your password are stored encrypted with an private key,
      #      # which also should NOT be kept in source code.
      #      {
      #          'admin' => some_logic_that_decrypt_password_into_plaintext()
      #      }[user]
      #    end
      #
      # @param actions_and_or_opts
      # @option actions_and_or_opts [Symbol] :type (:basic) one of :basic, :digest, :html
      # @option actions_and_or_opts [String] :realm ('Access Restricted') only used on :digest and :basic
      # @option actions_and_or_opts [String, nil] :body (nil) html template in case of :html
      #   and text to be displayed if auth skipped on :basic and :digest
      # @option actions_and_or_opts [Integer] :nonce_ttl (nil) number of seconds.
      #   will force browser to update the nonce each N seconds.
      #   only used on :digest auth.
      # @option actions_and_or_opts [Boolean] :plain (nil) if true, it informs that password is in plain text and should be hashed.
      #   only used on :digest.
      def auth *actions_and_or_opts, &proc

        if proc && configurable? # prohibit updates after node mounted

          actions, opts = [], {}
          actions_and_or_opts.each { |arg| arg.is_a?(Hash) ? opts.update(arg) : actions << arg }
          opts[:proc] = proc

          actions = ["*"] if actions.size == 0
          actions.each { |a| @restrictions[a] = opts }
        end

        action = actions_and_or_opts.first
        @setup['%s::%s' % [:auth, action]] ||= @restrictions[action] ||
            @restrictions['*'] ||
            (@node.node.partition.http.auth(action) if @node)
      end

      # by default, Presto will use an in memory cache pool.
      # it is well and fast as long as your content fit into available RAM.
      # to keep memory low, consider to use some fast key/value db.
      # @example use mongodb as cache pool:
      #    db = Mongo::Connection.new.db(:cache)
      #    http.cache_pool Presto::Cache::MongoDB.new db
      #
      # @attribute cache_pool
      # @param pool
      def cache_pool pool = nil
        @cache_pool = pool if pool && configurable?
        @setup[:cache_pool] ||= @cache_pool ||
            (@node.node.partition.http.cache_pool if @node) ||
            Presto.opts.cache_pool
      end

      # setting some actions(or all) to use cache.
      #
      # given block will be used to decide
      # which requests will use cache and which will not.
      #
      # *  if block returns any positive value, cache will be returned
      # *  if block returns :update [Symbol], cache will be updated then returned
      # otherwise a fresh version of action will be returned.
      #
      # @example caching all actions:
      #
      #    # callback receiving back the current action and its arguments.
      #    http.cache do |action, *arguments|
      #      cache = true
      #      cache = false if http.query_string =~ /no_cache/
      #      cache = :update if http.query_string =~ /update_cache/
      #      #and so on
      #      cache
      #    end
      #
      # @example caching #static action:
      #
      #    http.cache :static do |action, *arguments|
      #      true
      #    end
      #
      # @note if no actions given, all actions will use same setup.
      # @note block is required, cause it is a bad idea to leave cache out of control.
      # @note http hooks WILL BE EVER executed regardless cache.
      #
      # @param [Array] actions
      # @param [Proc] proc
      def cache *actions, &proc

        if proc && configurable? # prohibit updates after node mounted
          actions = ['*'] if actions.size == 0
          actions.each { |a| @cache[a] = proc }
        end

        action = actions.first
        @setup['%s::%s' % [:cache, action]] ||= @cache[action] ||
            @cache['*'] ||
            (@node.node.partition.http.cache(action) if @node)
      end

      # each node may have own middleware.
      # @example
      #    http.use SomeMiddleware, :with, some: :args
      #
      # @attribute middleware
      # @param [Class] ware
      # @param [Array] args
      # @param [Proc] proc
      def use ware, *args, &proc
        @middleware << {ware: ware, args: args, block: proc} if configurable?
      end

    end

  end
end
