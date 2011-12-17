require 'rack/test'
%w[
utils
frontend/assert
frontend/node_accessor
frontend/request
frontend/setup
frontend/frontend
backend/backend
backend/run
].each { |f| require File.expand_path(f, File.dirname(__FILE__)) }
