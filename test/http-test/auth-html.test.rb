require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestAuthHtml < MiniTest::Unit::TestCase

  include Capybara::DSL
  include Rack::Test::Methods

  attr_reader :app

  module App1

    class Controller

      include Presto::Api
      http.map "/"

      http.auth type: :html do |user, pass|
        user == "user" && pass == "up"
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

    class AdminArticles

      include Presto::Api
      http.map "/admin/articles"

      def index
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

      http.auth type: :html do |u,p|
        http.session[:top_secret_auth] ||= ([u,p] == ["top", "secret"]) && u
      end

      def index
        http.user
      end

    end
  end

  #def test_auth_set_by_client
  #
  #  app = Presto::App.new
  #  app.mount App1
  #  Capybara.app = app.map
  #
  #  visit "/"
  #  fill_in "username", with: "bad"
  #  fill_in "password", with: "guy"
  #  click_button "presto-authorization-html"
  #  assert_match page.html, /presto-authorization-html/
  #
  #  visit "/"
  #  fill_in "username", with: "user"
  #  fill_in "password", with: "up"
  #  click_button "presto-authorization-html"
  #  assert_match page.html, /user/
  #
  #end
  #
  #def test_auth_set_by_partition
  #
  #  app = Presto::App.new
  #  app.mount App2 do |p|
  #    p.http.auth type: :html do |user, pass|
  #      http.session[:auth] ||= (user == "root" && pass == "rp") && user
  #    end
  #  end
  #  Capybara.app = app.map
  #
  #  visit "/admin"
  #  fill_in "username", with: "bad"
  #  fill_in "password", with: "guy"
  #  click_button "presto-authorization-html"
  #  assert_match page.html, /presto-authorization-html/
  #
  #  visit "/admin"
  #  fill_in "username", with: "root"
  #  fill_in "password", with: "rp"
  #  click_button "presto-authorization-html"
  #  assert_match page.html, /root/
  #
  #  visit "/admin/articles"
  #  assert_match page.html, /root/
  #
  #  visit "/members"
  #  assert_match page.html, /root/
  #
  #  visit "/TopSecret"
  #  fill_in "username", with: "top"
  #  fill_in "password", with: "secret"
  #  click_button "presto-authorization-html"
  #  assert_match page.html, /top/
  #end

end
