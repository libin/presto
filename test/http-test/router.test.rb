require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestRouter

  module App

    class Controller

      include Presto::Api
      http.map "/"
      http.canonical "/old-url"

      def index
        "index"
      end

      def two_required_args_v1 arg1, arg2
        "#{arg1}/#{arg2}"
      end

      def two_required_args_v2 arg1 = 1, arg2
        "#{arg1}/#{arg2}"
      end

      def one_to_two_args arg1, arg2 = 2
        "#{arg1}/#{arg2}"
      end

      def zero_to_unlimited_args_v1 *args
        args.map { |a| a.to_s }.join("/")
      end

      def zero_to_unlimited_args_v2 arg1 = nil, *args
        arg1.to_s + "/" + args.map { |a| a.to_s }.join("/")
      end

      def one_to_unlimited_args_v1 arg1, *args
        arg1 + "/" + args.map { |a| a.to_s }.join("/")
      end

      def one_to_unlimited_args_v2 *args, last
        args.map { |a| a.to_s }.join("/") + "/" + last.to_s
      end

      def one_to_unlimited_args_v3 arg = nil, *args, last
        arg.to_s + "/" + args.map { |a| a.to_s }.join("/") + "/" + last.to_s
      end

      def two_to_unlimited_args_v1 arg1, arg2, *args
        arg1.to_s + "/" + arg2.to_s + "/" + args.map { |a| a.to_s }.join("/")
      end

      def two_to_unlimited_args_v2 arg, *args, last
        arg.to_s + "/" + args.map { |a| a.to_s }.join("/") + "/" + last.to_s
      end

    end
  end

  module Browser

    include Rack::Test::Methods

    def request action, *args

      args = args.map { |a| a.to_s }.join("/")
      url = @baseurl + action.to_s + "/" + args
      get url
      [last_response.status, last_response.body, url]
    end

    def flexible_body_request expected_status, action, *args

      status, body, url = request action, *args
      expected_body = args.map { |a| a.to_s }.join("/")

      assert_equal status, expected_status, "
      ---
      url: #{url}
      status expected: #{expected_status}
      status returned: #{status}
      "
      assert_match body, /#{expected_body}/ unless status == 404
    end

    def fixed_body_request expected_status, expected_body, action, *args

      status, body, url = request action, *args

      assert_equal status, expected_status, "
      ---
      url: #{url}
      status expected: #{expected_status}
      status returned: #{status}
      "
      assert_equal body, expected_body unless status == 404
    end
  end

  module MockBrowser

    def request action, *args

      browser = Presto::Browser.new(App::Controller)
      response = browser.request action, *args
      status = response[0]
      body = response[2].body.join rescue nil
      [status, body]
    end

    def flexible_body_request expected_status, action, *args

      status, body = request action, *args
      expected_body = args.map { |a| a.to_s }.join("/")

      assert_equal expected_status, status
      assert_match expected_body, body unless status == 404

      if status == 200
        response = App::Controller.http.get(action, *args)
        assert_match expected_body, response
      end
    end

    def fixed_body_request expected_status, expected_body, action, *args

      status, body = request action, *args

      assert_equal expected_status, status
      assert_equal expected_body, body unless status == 404

      if status == 200
        response = App::Controller.http.get(action, *args)
        assert_equal expected_body, response
      end
    end
  end

  module Tests

    def test_index

      body = "index"
      action = :index
      fixed_body_request 404, body, action, 1
      fixed_body_request 200, body, action
    end

    def test_two_required_args_v1

      action = :two_required_args_v1
      flexible_body_request 404, action
      flexible_body_request 404, action, 1
      flexible_body_request 200, action, 1, 2
    end

    def test_two_required_args_v2

      action = :two_required_args_v2
      flexible_body_request 404, action
      flexible_body_request 404, action, 1
      flexible_body_request 200, action, 1, 2
    end

    def test_one_to_two_args

      action = :one_to_two_args
      flexible_body_request 404, action
      flexible_body_request 200, action, 1
      flexible_body_request 200, action, 1, 2
    end

    def test_zero_to_unlimited_args_v1

      action = :zero_to_unlimited_args_v1
      flexible_body_request 200, action
      flexible_body_request 200, action, 1
      flexible_body_request 200, action, 1, 2
      flexible_body_request 200, action, 1, 2, 3
      flexible_body_request 200, action, 1, 2, 3, 4
      flexible_body_request 200, action, 1, 2, 3, 4, 5
    end

    def test_zero_to_unlimited_args_v2

      action = :zero_to_unlimited_args_v2
      fixed_body_request 200, "/", action
      flexible_body_request 200, action, 1
      flexible_body_request 200, action, 1, 2
      flexible_body_request 200, action, 1, 2, 3
      flexible_body_request 200, action, 1, 2, 3, 4
      flexible_body_request 200, action, 1, 2, 3, 4, 5
    end

    def test_one_to_unlimited_args_v1

      action = :one_to_unlimited_args_v1
      fixed_body_request 404, "1/", action
      fixed_body_request 200, "1/", action, 1
      fixed_body_request 200, "1/2", action, 1, 2
      fixed_body_request 200, "1/2/3", action, 1, 2, 3
    end

    def test_one_to_unlimited_args_v2

      action = :one_to_unlimited_args_v2
      flexible_body_request 404, action
      fixed_body_request 200, "/1", action, 1
      fixed_body_request 200, "1/2", action, 1, 2
      fixed_body_request 200, "1/2/3", action, 1, 2, 3
    end

    def test_one_to_unlimited_args_v3

      action = :one_to_unlimited_args_v3
      flexible_body_request 404, action
      fixed_body_request 200, "//1", action, 1
      fixed_body_request 200, "1//2", action, 1, 2
      fixed_body_request 200, "1/2/3", action, 1, 2, 3
    end

    def test_two_to_unlimited_args_v1

      action = :two_to_unlimited_args_v1
      flexible_body_request 404, action
      fixed_body_request 200, "1/2/", action, 1, 2
      fixed_body_request 200, "1/2/3", action, 1, 2, 3
    end

    def test_two_to_unlimited_args_v2

      action = :two_to_unlimited_args_v2
      flexible_body_request 404, action
      fixed_body_request 200, "1//2", action, 1, 2
      fixed_body_request 200, "1/2/3", action, 1, 2, 3
    end
  end

  class BasicTest < MiniTest::Unit::TestCase

    include Browser
    include Tests

    def setup
      @baseurl = "/"
    end

    def app
      app = Presto::App.new
      app.mount App
      app.map
    end

  end

  class CanonicalTest < MiniTest::Unit::TestCase

    include Browser
    include Tests

    def setup
      @baseurl = "/old-url/"
    end

    def app
      app = Presto::App.new
      app.mount App
      app.map
    end

  end

  class AppMockTest < MiniTest::Unit::TestCase

    def setup
      app = Presto::App.new
      app.mount App
      app.map
    end

    include MockBrowser
    include Tests

  end

end
