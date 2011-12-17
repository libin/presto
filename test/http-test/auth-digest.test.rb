require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestAuthDigest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  attr_reader :app

  module App1

    class Controller

      include Presto::Api
      http.map "/"

      http.auth type: :digest, plain: true, realm: 'test' do |user|
        {
            'user' => 'up'
        }[user]
      end

      http.auth :edit, type: :digest, plain: true, realm: 'test'  do |user|
        {
            'admin' => 'ap'
        }[user]
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

      http.auth type: :digest, realm: 'test' do |user|
        {
            'top' => '25577f8bfecc4434dcd76c32a26cb8f5'
        }[user]
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

    digest_authorize "user", ""
    response = get "/"
    assert_equal 401, response.status

    digest_authorize "user", "up"
    response = get "/"
    assert_equal 'user', response.body

    response = get "/edit"
    assert_equal 401, response.status

    digest_authorize "admin", "ap"
    response = get "/edit"
    assert_equal 'admin', response.body

  end

  def test_auth_set_by_partition

    app = Presto::App.new
    app.mount App2 do |p|
      p.http.auth type: :digest, realm: 'test' do |user|
        {
            'root' => '61bfd9ee87d373603ac5763f378b8e40',
        }[user]
      end
    end
    @app = app.map

    digest_authorize "root", ""
    response = get "/admin"
    assert_equal 401, response.status

    digest_authorize "root", "rp"
    response = get "/admin"
    assert_equal 'root', response.body

    response = get "/members"
    assert_equal 200, response.status

    response = get "/TopSecret"
    assert_equal 401, response.status

    digest_authorize "top", "secret"
    response = get "/TopSecret"
    assert_equal 'top', response.body

  end

end
