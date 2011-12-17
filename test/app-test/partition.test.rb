require ::File.expand_path("_init", ::File.dirname(__FILE__))

module TestPartitioning

  class BasicTest < MiniTest::Unit::TestCase

    module App1

      class Controller

        include Presto::Api
        http.map "index"
      end
    end

    module App2

      module Helper

        include Presto::Api
      end
      class Controller

        include Presto::Api
        http.map "index"
      end
    end

    def test_app1

      app = Presto::App.new
      app.mount( App1, "/app1/" ) do |p|
        p.view.root "view-root"
      end
      assert_equal "/app1/index/", App1::Controller.http.route
      assert_equal "/view-root/", App1::Controller.node.partition.view.root
      assert_match "TestPartitioning::BasicTest::App1", App1::Controller.node.namespace
    end

    def test_app2

      app = Presto::App.new
      app.mount(App2)
      assert_equal "/index/", App2::Controller.http.route
      assert_match "TestPartitioning::BasicTest::App2", App2::Helper.node.namespace
      assert_match "TestPartitioning::BasicTest::App2", App2::Controller.node.namespace
    end

  end
end
