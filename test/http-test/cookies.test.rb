require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestCookies < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  VARS = Hash.new

  module App

    class Controller

      include Presto::Api
      http.map

      http.before :readonly do
        http.cookies.confine
      end

      def get_cookie key
        http.cookies[key]
      end
      
      def set_cookie key, val
        http.cookies[key] = val
      end

      def delete_cookie key
        http.cookies.delete key
      end

      def readonly key, val
        http.cookies[key] = val
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount(App)
    app.map
  end

  def test_set_and_delete_cookie
    
    get "/set_cookie/k/v"
    assert_equal "v", rack_mock_session.cookie_jar['k']

    clear_cookies
    refute rack_mock_session.cookie_jar['k']

    get "/readonly/k/v"
    refute rack_mock_session.cookie_jar['k']
  end

end
