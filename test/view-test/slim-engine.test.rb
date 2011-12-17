require ::File.expand_path("_init", ::File.dirname(__FILE__))
require 'slim'
Slim::Engine.set_default_options :pretty => true
Presto::View.register :Slim, Slim::Template

class SlimEngineApp

  include Presto::Api
  http.map
  view.engine :Slim
  view.root File.expand_path('./view-slim', File.dirname(__FILE__))

  attr_reader :items

  def index
    @items = [
        Struct.new(:name, :price).new('item #1', 99.99),
        Struct.new(:name, :price).new('item #2', 143.05),
    ]
    view.render
  end
  
end

class SlimEngineTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    app = Presto::App.new
    app.mount SlimEngineApp
    app.map
  end

  def test_slim_engine
    response = get '/'
    assert_match /item #1/, response.body
    assert_match /item #2/, response.body
  end
end
