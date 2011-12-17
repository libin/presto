require "ap" rescue nil
require "minitest/autorun"
require "mongo"
require "fileutils"
require "rack"
require "rack/test"

require ::File.expand_path("../lib/presto", ::File.dirname(__FILE__))

MONGODB_PORT = 20_000
MONGODB_PATH = "/tmp/presto/mongodb/"
begin
  MONGODB_CONN = Mongo::Connection.new("localhost", MONGODB_PORT)
rescue
  puts
  puts '*'*80
  puts
  puts "MongoDB Connection Failure. Make sure mongodb is running on #{ MONGODB_PORT }"
  puts "to start it use:"
  puts
  puts "rm -fr \"#{MONGODB_PATH}\"; mkdir -p \"#{MONGODB_PATH}\"; mongod --port #{MONGODB_PORT} --dbpath \"#{MONGODB_PATH}\" "
  puts
  puts '*'*80
  puts
  exit 1
end
