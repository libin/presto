require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestAlias < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  module App

    class Controller

      include Presto::Api
      http.map "/"

      http.alias :_node_, :node
      http.alias :_http_, :http, :HTTP, :Http
      http.alias :_view_, :view, :views, :Views


      def _node_
        
      end

      def _http_

      end

      def _view_
        
      end

      http.alias :prefix_me, :articles__prefix_me
      def prefix_me
        
      end

      http.alias :suffix_me, :suffix_me____html
      def suffix_me
        
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount(App)
    app.map
  end

  def test_alias
    
    response = get "/_node_"
    assert_equal 200, response.status

    response = get "/node"
    assert_equal 200, response.status

    response = get "/_http_"
    assert_equal 200, response.status

    response = get "/http"
    assert_equal 200, response.status

    response = get "/HTTP"
    assert_equal 200, response.status

    response = get "/Http"
    assert_equal 200, response.status

    response = get "/_view_"
    assert_equal 200, response.status

    response = get "/view"
    assert_equal 200, response.status

    response = get "/views"
    assert_equal 200, response.status

    response = get "/Views"
    assert_equal 200, response.status

    response = get "/articles/prefix_me"
    assert_equal 200, response.status

    response = get "/suffix_me.html"
    assert_equal 200, response.status

  end

end
