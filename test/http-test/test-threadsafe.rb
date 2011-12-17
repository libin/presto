require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestThreadSafe < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  module App

    class Controller

      include Presto::Api
      http.map "/"

      def index
        http.params["k"]
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount App
    app.map
  end

  def rack_mock

    order = 0
    threads = Array.new
    10.times do |i|
      threads[i] = Thread.new do
        sleep(rand(0)/10.0)
        order += 1
        Thread.current["order"] = "#{order}"
        get( "/index/?k=#{order}").body
      end
    end

    threads.each do |t|
      response = t.value
      puts "thread #{t["order"]}: #{ response }"
      assert_equal t["order"], response
    end
  end

  def app_mock

    app()
    
    order = 0
    threads = Array.new
    10.times do |i|
      threads[i] = Thread.new do
        sleep(rand(0)/10.0)
        order += 1
        Thread.current["order"] = "#{order}"
        App::Controller.http.get(:index, "k" =>order)
      end
    end

    threads.each do |t|
      response = t.value
      puts "thread #{t["order"]}: #{ response }"
      assert_equal t["order"], response
    end

  end

  def test_via_rack_mock

    10.times { rack_mock }
  end

  def test_via_app_mock

    10.times { app_mock }
  end

end
