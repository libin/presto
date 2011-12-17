require "cgi/util"
require "rack"
require "erb"
require "digest/md5"

module Presto

  VERSION = "0.0.6"

  DEBUG_DISABLED = 0.freeze
  DEBUG_LIMITED = 1.freeze
  DEBUG_ENABLED = 2.freeze

  # default options
  path_rules = {
      "____" => ".",
      "___" => "-",
      "__" => "/",
  }
  session_opts = [:pool, :cookie_name, :ttl]
  view_opts = [:engine, :ext]
  OPTS = {
      content_type: nil,
      path_rules: path_rules,
      cache_pool: nil,
      session: Struct.new(*session_opts).new,
      view: Struct.new(*view_opts).new,
      debug: nil,
  }

  class << self

    attr_reader :middleware

    # store nodes to be served
    # @return [Array]
    def nodes
      @nodes ||= Array.new
    end

    # store default Presto configuration
    # @return [Struct]
    def opts
      @opts ||= Struct.new(*OPTS.keys).new(*OPTS.values)
    end

    # store middleware to be used by all namespaces, respectively by all nodes.
    # @return [Array]
    def use ware, *args, &blk
      (@middleware ||= Array.new) << {ware: ware, args: args, block: blk}
    end
  end
end

wd = ::File.expand_path(::File.dirname(__FILE__)) + '/presto/'
require '%s/../tilt/lib/tilt' % wd

%w[
utils
node
browser
].each { |f| require File.join(wd, f) }

%w[
cache
http
view
test
].each { |mod| require File.join(wd, mod, mod) }

%w[
mixin
mapper
partition
app
].each { |f| require File.join(wd, f) }

Presto.opts.debug = Presto::DEBUG_ENABLED
Presto.opts.content_type = Presto::HTTP::CONTENT_TYPE_HTML
Presto.opts.cache_pool = Presto::Cache::Memory.new

Presto.opts.view.engine = ::Tilt::ErubisTemplate
Presto.opts.view.ext = 'rhtml'

Presto.opts.session.ttl = 86_400
Presto.opts.session.cookie_name = 'presto.sid'
Presto.opts.session.pool = Presto.opts.cache_pool

# cosmetically prohibit methods overriding
module Presto
  [Utils, InternalUtils, Browser, App, Api, Api::InstanceMixin].each { |c| c.freeze }
  class << self
    self.freeze
  end
end
