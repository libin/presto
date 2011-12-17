require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestRedirect < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  VARS = Hash.new

  module App

    class Controller

      include Presto::Api
      http.map "/"

      def index
        "index"
      end

      def redirect
        http.redirect :index
        # code here never executed
        VARS['redirected'] = true
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount App
    app.map
  end

  def test_redirect

    VARS['redirected'] = false
    response = get("/redirect")
    assert_equal 302, response.status
    refute VARS['redirected']
  end

end
