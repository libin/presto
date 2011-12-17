require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestPathRules < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  attr_accessor :app

  module DefaultRules

    class Controller

      include Presto::Api
      http.map "/"

      def four____slashes
        "four.slashes"
      end

      def three___slashes
        "three-slashes"
      end

      def two__slashes
        "two/slashes"
      end

    end
  end

  module CustomRules

    class Controller

      include Presto::Api
      http.map "/"

      def slash__html
        "slash/html"
      end

      def dot_dot_html
        "dot.html"
      end

      def dash_dash_html
        "dash-html"
      end

      def comma_comma_html
        "comma,html"
      end

      def brackets_obr_html_cbr_
        "brackets(html)"
      end

    end
  end

  def test_default_rules

    app = Presto::App.new
    app.mount DefaultRules
    @app = app.map

    %w[
    four.slashes
    three-slashes
    two/slashes
    ].each do |action|
      response = get("/" + action)
      assert_equal action, response.body
    end

  end

  def test_custom_rules

    app = Presto::App.new
    app.mount CustomRules do |p|
      p.http.path_rules({
                            "__" => "/",
                            "_dot_" => ".",
                            "_dash_" => "-",
                            "_comma_" => ",",
                            "_obr_" => "(",
                            "_cbr_" => ")",
                        })
    end
    @app = app.map
    
    %w[
    slash/html
    dot.html
    dash-html
    comma,html
    brackets(html)
    ].each do |action|
      response = get("/" + action)
      assert_equal action, response.body
    end

  end

end
