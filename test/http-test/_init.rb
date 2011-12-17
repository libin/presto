require ::File.expand_path("../_init", ::File.dirname(__FILE__))
require "capybara"
require "capybara/dsl"

Capybara.current_driver = :selenium
Capybara.default_selector = :xpath
API_METHODS = Presto::HTTP::ClassApi.instance_methods(false)
Rack::Test::DEFAULT_HOST = "presto.org"
