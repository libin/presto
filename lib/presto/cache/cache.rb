require 'monitor'
require 'digest/md5'

module Presto
  module Cache
  end
end

wd = ::File.expand_path(::File.dirname(__FILE__)) + '/'
require wd + 'api'
Dir[wd + 'store/*.rb'].each { |f| require f }

module Presto::Cache
  Api.freeze
  Memory.freeze
  Memory::Store.freeze
  MongoDB.freeze
  MongoDB::Store.freeze
end
