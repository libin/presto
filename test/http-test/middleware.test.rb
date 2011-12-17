require ::File.expand_path("_init", ::File.dirname(__FILE__))

module TestMiddleware

  class AppWare

    def initialize(app)
      @app = app
    end

    def call(env)

      (env['WARES'] ||= Array.new) << "AppWare"
      @app.call(env)
    end

  end

  class ClientWare

    def initialize(app)
      @app = app
    end

    def call(env)

      (env['WARES'] ||= Array.new) << "ClientWare"
      @app.call(env)
    end

  end

  class TestMiddlewareSetByNode < MiniTest::Unit::TestCase

    class App
      include Presto::Api
      http.map
      http.use ClientWare

      def index
        http.env['WARES'].size
      end
    end

    include Rack::Test::Methods
    attr_reader :app

    def test_middleware_set_by_node

      app = Presto::App.new
      app.mount App
      @app = app.map

      assert_equal '1', get("/").body
    end
  end

  class TestMiddlewareSetByPartition < MiniTest::Unit::TestCase

    class App
      include Presto::Api
      http.map
      http.use ClientWare

      def index
        http.env['WARES'].size
      end
    end

    include Rack::Test::Methods
    attr_reader :app

    def test_middleware_set_by_partition

      app = Presto::App.new
      app.mount App do |p|
        p.http.use AppWare
      end
      @app = app.map

      assert_equal '2', get("/").body
    end
  end
end
