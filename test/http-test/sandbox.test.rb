require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestSandbox < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  module App

    class Controller

      include Presto::Api
      http.map

      http.before do
        http.confine
      end
      http.before :allow_redirect do
        http.confine :redirect
      end

      def index action
        action if http.respond_to?(action.to_sym)
      end

      def allow_redirect
        true if http.respond_to?(:redirect)
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount(App)
    app.map
  end

  def test_sandbox

    response = get '/params'
    assert_equal 'params', response.body

    response = get '/session'
    assert_equal '', response.body

    response = get '/allow_redirect/'
    assert_equal 'true', response.body

  end

end
