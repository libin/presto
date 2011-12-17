require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestMixin < MiniTest::Unit::TestCase

  module App

    class Controller
      include Presto::Api
    end
  end

  def setup
    app = Presto::App.new
    app.mount App
    app.map
    @tested_class = App::Controller
  end

  def test_class_respond_to_http

    assert_respond_to @tested_class, :http
  end

  def test_class_http_respond_to

    API_METHODS.each do |m|
      assert_respond_to @tested_class.http, m
    end
  end

end
