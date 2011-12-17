require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestCache < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  ACTIONS = Array.new

  module App

    class Controller

      include Presto::Api
      http.map "/"

      http.cache :set_by_query_string do |action, fresh|
        http.query_string =~ /fresh/ ? false : true
      end

      http.cache :set_by_params do |action, fresh|
        !fresh
      end

      http.cache do |action|
        instruction = true
        if action == :heavy_action
          instruction = :update if http.query_string =~ /cache_update/
          instruction = false if http.query_string =~ /cache_skip/
        end
        instruction
      end

      def set_by_query_string
        ACTIONS << :set_by_query_string
      end

      def set_by_params fresh = false
        fresh && ACTIONS << :set_by_params
      end

      def heavy_action
        http.params['k']
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount App
    app.map
  end

  def test_manage_cache_by_action_params

    10.times do
      ACTIONS.clear
      get "/set_by_params/true"
      assert_includes ACTIONS, :set_by_params
    end

    # caching
    get "/set_by_params/"
    ACTIONS.clear

    # checking action is not executed
    10.times do
      get "/set_by_params/"
    end
    assert_empty ACTIONS
  end

  def test_manage_cache_by_query_string

    # checking actions is ever executed
    10.times do
      ACTIONS.clear
      get "/set_by_query_string/?fresh"
      assert_includes ACTIONS, :set_by_query_string
    end

    # caching
    get "/set_by_query_string/"
    ACTIONS.clear

    # checking action is not executed
    10.times do
      get "/set_by_query_string/"
    end
    assert_empty ACTIONS
  end

  def test_cache_update_and_skip

    url = "/heavy_action/"
    test = lambda do |val|
      assert_equal val, get(url + "?k=1").body
      assert_equal val, get(url + "?k=2").body
      assert_equal val, get(url + "?k=anything").body
    end

    # caching action
    get(url + "?k=val")
    # testing cache
    test.call "val"

    # updating cache by sending cache_update in query_string
    get(url + "?cache_update&k=cache_updated?")
    # testing cache
    test.call "cache_updated?"

    # skipping cache
    assert_equal "cache_skipped?", get(url + "?cache_skip&k=cache_skipped?").body
    assert_equal "yes-cache_skipped", get(url + "?cache_skip&k=yes-cache_skipped").body

  end

end
