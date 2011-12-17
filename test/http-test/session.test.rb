require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestSession

  module App

    class Controller

      include Presto::Api
      http.map

      http.before :readonly do
        http.session.confine
      end

      def set_session k, v
        http.session[k] = {k => v}
      end

      def get_session k
        http.session[k][k] rescue nil
      end

      def set_flash k, v
        http.flash[k] = v
      end

      def get_flash k
        http.flash[k]
      end

      def session_sweeper
        http.session.sweep
      end

      def readonly k, v
        http.session[k] = v
        http.session[k]
      end

    end
  end

  module Tests

    def check_session_expired

      key = "session_expired" + rand(1000).to_s
      val = rand(1000).to_s
      get("/set_session/#{key}/#{val}")
      response = get("/get_session/#{key}")
      assert_equal val, response.body

      # calling session sweeper
      get "/session_sweeper"

      # session should be expired and purged
      response = get("/get_session/#{key}")
      assert_equal "", response.body

    end

    def check_session_alive
      key = "session_alive" + rand(1000).to_s
      val = rand(1000).to_s
      get("/set_session/#{key}/#{val}")
      response = get("/get_session/#{key}")
      assert_equal val, response.body
    end

    def check_flash

      key = "flash" + rand.to_s
      val = rand.to_s
      get("/set_flash/#{key}/#{val}")

      # checking flash was set
      response = get("/get_flash/#{key}")
      assert_equal val, response.body

      # checking flash was wiped after use
      response = get("/get_flash/#{key}")
      assert_equal '', response.body
    end

    def check_readonly
      key, val = rand.to_s, rand.to_s
      response = get '/readonly/%s/%s' % [key, val]
      assert_equal '', response.body
    end

  end

  class MemoryPool < MiniTest::Unit::TestCase

    include Rack::Test::Methods
    include Tests
    attr_reader :app

    def test_session_expired

      Presto.opts.session.ttl = -10
      app = Presto::App.new
      app.mount App do |p|
      end
      @app = app.map

      check_session_expired

    end

    def test_session_alive_and_flash

      Presto.opts.session.ttl = 86_400

      app = Presto::App.new
      app.mount App
      @app = app.map

      check_session_alive
      check_flash
      check_readonly
    end

  end

  class MongoDBPool < MiniTest::Unit::TestCase

    include Rack::Test::Methods
    include Tests
    attr_reader :app

    POOL = Presto::Cache::MongoDB.new(MONGODB_CONN.db('presto-session_test'))

    def test_session_expired

      Presto.opts.session.pool = POOL
      Presto.opts.session.ttl = -10

      app = Presto::App.new
      app.mount App
      @app = app.map

      check_session_expired
    end

    def test_session_alive_and_flash

      Presto.opts.session.ttl = 86_400

      app = Presto::App.new
      app.mount App
      @app = app.map

      check_session_alive
      check_flash
      check_readonly
    end
  end

end
