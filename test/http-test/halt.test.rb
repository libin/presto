require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestHalt < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  VARS = Hash.new

  module App

    class Controller

      include Presto::Api
      http.map "/"

      def halt_quietly
        http.halt
        VARS["halted"] = true
      end

      def halt_with_message
        http.halt "halted"
        VARS["halted"] = true
      end

      def halt_with_message_and_status
        http.halt "halted", status: 500
        VARS["halted"] = true
      end

      def headers
        http.halt "body{ margin: 100px; }", 'Content-Type' => http.mime_type('.css')
      end

    end
  end

  def app
    app = Presto::App.new
    app.mount App
    app.map
  end

  def test_halt_quietly
    VARS["halted"] = false
    response = get( "/halt_quietly" )
    assert_equal "", response.body
    assert_equal false, VARS["halted"]
  end

  def test_halt_with_message
    VARS["halted"] = false
    response = get( "/halt_with_message" )
    assert_equal "halted", response.body
    assert_equal false, VARS["halted"]
  end

  def test_halt_with_message_and_status
    VARS["halted"] = false
    response = get( "/halt_with_message_and_status" )
    assert_equal "halted", response.body
    assert_equal 500, response.status
    assert_equal false, VARS["halted"]
  end

  def test_headers
    rsp = get '/headers'
    assert_match rsp.body, /margin/
    assert_equal rsp.headers['Content-Type'], 'text/css'
  end

end
