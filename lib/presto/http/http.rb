module Presto
  module HTTP

    CONTENT_TYPE_PLAIN = "text/plain"
    CONTENT_TYPE_HTML = "text/html"

  end
end

wd = ::File.expand_path(::File.dirname(__FILE__)) + '/'

%w[
config
partition
].each { |f| require File.join(wd, f) }

%w[
auth
response
api/shared
api/class
api/instance
].each { |dir| Dir[wd + dir + "/*.rb"].each { |f| require f } }

# cosmetically prohibit methods overriding
module Presto::HTTP
  Config.freeze
  SharedApi.freeze
  ClassApi.freeze
  Response.freeze
  Partition.freeze
  class InstanceApi
    self.freeze
    SessionProxy.freeze
    CookiesProxy.freeze
  end
  module Auth
    self.freeze
    Basic.freeze
    Digest.freeze
    Html.freeze
  end
end
