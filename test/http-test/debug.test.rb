require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestDebug < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  module App

    class Controller

      include Presto::Api
      http.map "/"

      def error
        some_error
      end

    end
  end

  attr_accessor :app

  def test_debug_enabled

    Presto.opts.debug = Presto::DEBUG_ENABLED
    
    app = Presto::App.new
    app.mount App
    @app = app.map

    assert_raises NameError do
      get("/error")
    end
  end

  def test_debug_limited

    Presto.opts.debug = Presto::DEBUG_LIMITED

    app = Presto::App.new
    app.mount App
    @app = app.map

    response = get("/error")
    assert_match /undefined.*error/, response.body
    assert_equal 500, response.status
  end

  def test_debug_disabled

    Presto.opts.debug = Presto::DEBUG_DISABLED

    app = Presto::App.new
    app.mount App
    @app = app.map

    response = get("/error")
    assert_match /error/i, response.body
    assert_equal 500, response.status
  end

end
