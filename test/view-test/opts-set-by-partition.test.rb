require ::File.expand_path("_init", ::File.dirname(__FILE__))

class OptsSetByPartition

  include Presto::Api
  http.map

  def compiler_test
    # first render should cache compiled template
    view.render_partial
    # second render should not try to read the file
    tpl = view.root + 'compiler_test.' + view.ext
    tmp = tpl + '-tmp'
    FileUtils.mv(tpl, tmp)
    output = view.render_partial rescue nil
    FileUtils.mv(tmp, tpl)
    output
  end

  def render param = nil
    @param = param
    view.render
  end

  def render_with_layout param = nil
    @param = param
    view.render
  end

  def render_action param = nil
    @param = param
    view.render_view(:render)
  end

  def render_file file
    view.render_view(file)
  end

  def render_partial file
    view.render_partial(file)
  end

  def render_layout output
    view.render_layout output
  end

  def render_haml_layout output
    view.render_haml_layout output
  end

  def render_haml
    view.render_haml
  end

  def render_haml_action
    view.render_haml_view(:render_haml)
  end

  def render_haml_file
    view.render_haml_view("haml-file")
  end

end

class TestOptsSetByPartition < MiniTest::Unit::TestCase

  include Rack::Test::Methods
  include BasicTests

  def app
    unless @app
      @app = Presto::App.new
      @app.mount OptsSetByPartition do
        view.root File.expand_path './view-default', File.dirname(__FILE__)
        view.layouts_root view.root
        view.layout 'layout'
        view.compile :compiler_test do
          true
        end
        view.compiler_pool Presto::Cache::MongoDB.new(MONGODB_CONN.db('presto-view_test'))
      end
    end
    @app.map
  end

end
