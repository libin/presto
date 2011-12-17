require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestMime < MiniTest::Unit::TestCase

  class App

    class Controller

      include Presto::Api
      http.map "/"

      def index
      end
    end
  end

  module Rss

    class Controller

      include Presto::Api
      http.map "/"
      http.content_type { http.mime_type(".rss") }

      def index
      end

    end
  end

  def test_mime_set_by_app

    type = Rack::Mime.mime_type(".xml")

    app = Presto::App.new
    app.mount App do |p|
      p.http.content_type { http.mime_type('.xml') }
    end
    app.map

    browser = Presto::Browser.new(App::Controller)
    response = browser.request :index
    assert_equal 200, response[0]
    assert_equal response[1]["Content-Type"], type
  end

  def test_rss

    app = Presto::App.new
    app.mount Rss
    app.map

    browser = Presto::Browser.new(Rss::Controller)
    response = browser.request :index
    assert_equal 200, response[0]
    assert_equal response[1]["Content-Type"], Rack::Mime.mime_type(".rss")
  end

end
