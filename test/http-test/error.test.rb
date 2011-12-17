require ::File.expand_path("_init", ::File.dirname(__FILE__))

module TestErrorMixin

  def test_404

    response = get('/5897zXJLKC37')
    assert_equal 404, response.status
    assert_equal 'index', response.body
  end

  def test_404_through_halt

    action = "action_returns_404"
    response = get('/' + action)
    assert_equal 404, response.status
    assert_equal '', response.body

    body = 'halted'
    action = "action_returns_404"
    response = get('/' + action + '/' + body)
    assert_equal 404, response.status
    assert_equal body, response.body
  end
end

class TestErrorSetByPartition < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  module App

    class Controller

      include Presto::Api
      http.map "/"

      def index

      end

      def action_returns_404 body = nil
        http.halt body, status: 404
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount App do |cfg|
      cfg.http.error 404 do
        http.action
      end
    end
    app.map
  end

  include TestErrorMixin

end

class TestErrorSetByNode < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  module App

    class Controller

      include Presto::Api
      http.map "/"
      http.error 404 do
        http.action
      end

      def index

      end

      def action_returns_404 body = nil
        http.halt body, status: 404
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount App
    app.map
  end

  include TestErrorMixin

end
