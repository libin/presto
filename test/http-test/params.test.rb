require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestParams < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  module App

    class Controller

      include Presto::Api
      http.map "/"

      def index
        http.params["k"]
      end

      def get
        http.get_params["k"]
      end

      def post
        http.post_params["k"]
      end

    end
  end

  def test_with_rack_mock

    app = Presto::App.new
    app.mount(App)
    browser = Rack::Test::Session.new(app.map)
    
    response = browser.get( "/?k=v")
    assert_equal "v", response.body

    response = browser.get( "/get/?k=v")
    assert_equal "v", response.body

    response = browser.post( "/post", "k" => "v")
    assert_equal "v", response.body
  end

  def test_with_app_mock

    app = Presto::App.new
    app.mount(App)

    response = App::Controller.http.get(:index, "k" =>"v")
    assert_equal "v", response

    response = App::Controller.http.post(:post, "k" =>"v")
    assert_equal "v", response

  end

end
