require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestAuth < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  attr_reader :app

  module App1

    class Controller

      include Presto::Api
      http.map "/"

      http.auth do |user, pass|
        user == "user" && pass == "up"
      end

      http.auth :edit do |user, pass|
        user == "admin" && pass == "ap"
      end

      def index
        http.user
      end

      def edit
        http.user
      end

    end
  end

  module App2

    class Admin

      include Presto::Api
      http.map "/admin"

      def index
        http.user
      end

      def edit
        http.user
      end

    end

    class Members

      include Presto::Api
      http.map "/members"

      def index
        http.user
      end
    end

    class TopSecret
      include Presto::Api
      http.map "/TopSecret"

      http.auth do |u,p|
        [u,p] == ["top", "secret"]
      end

      def index
        http.user
      end

    end
  end

  def test_auth_set_by_client

    app = Presto::App.new
    app.mount App1
    @app = app.map

    authorize "user", ""
    response = get "/"
    assert_equal 401, response.status

    authorize "user", "up"
    response = get "/"
    assert_equal 200, response.status

    response = get "/edit"
    assert_equal 401, response.status

    authorize "admin", "ap"
    response = get "/edit"
    assert_equal 200, response.status

  end

  def test_auth_set_by_partition

    app = Presto::App.new
    app.mount App2 do |p|
      p.http.auth do |user, pass|
        user == "root" && pass == "rp"
      end
    end
    @app = app.map

    authorize "root", ""
    response = get "/admin"
    assert_equal 401, response.status

    authorize "root", "rp"

    response = get "/admin"
    assert_equal 200, response.status

    response = get "/members"
    assert_equal 200, response.status

    response = get "/TopSecret"
    assert_equal 401, response.status

    authorize "top", "secret"
    response = get "/TopSecret"
    assert_equal 200, response.status

  end

end
