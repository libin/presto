require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestHooks < MiniTest::Unit::TestCase

  HOOKS = Array.new

  module App

    class Controller

      include Presto::Api
      http.map "/"

      http.before do
        HOOKS << "before_all"
      end

      http.before :index do
        HOOKS << "before_index"
      end

      http.after do
        HOOKS << "after_all"
      end

      http.after :index do
        HOOKS << "after_index"
      end

      def index
      end

      def global
      end

    end
  end

  def setup
    app = Presto::App.new
    app.mount App
    app.map
  end

  def clear_hooks
    HOOKS.dup.each { |h| HOOKS.delete(h) }
  end

  def test_global_hooks

    clear_hooks()
    App::Controller.http.get(:global)
    assert_equal ["before_all", "after_all"], HOOKS

    clear_hooks()
    App::Controller.http.get(:index)
    assert_includes HOOKS, "before_all"
    assert_includes HOOKS, "after_all"
  end

  def test_index_hooks

    clear_hooks()
    App::Controller.http.get(:index)
    assert_equal ["before_all", "before_index", "after_all", "after_index"], HOOKS
  end

end
