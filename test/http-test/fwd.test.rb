require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestFwd < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  module App
    class Controller

      include Presto::Api
      http.map "/"

      def index key, val
        http.fwd :details
        "index"
      end

      def details *args
        [args, http.params]
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount(App)
    app.map
  end

  ARGS = ["k", "v"]
  PARAMS = {"var" => "val"}

  def test_get_fwd
    body = get(ARGS.join("/") + "?" + Rack::Utils.build_query(PARAMS)).body
    refute_match /index/, body
    assert_match /#{[ARGS, PARAMS]}/, body
  end

  def test_post_fwd
    body = post(ARGS.join("/") + "?" + Rack::Utils.build_query(PARAMS)).body
    refute_match /index/, body
    assert_match /#{[ARGS, PARAMS]}/, body
  end

end
