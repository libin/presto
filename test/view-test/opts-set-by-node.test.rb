require ::File.expand_path("_init", ::File.dirname(__FILE__))

class OptsSetByNode

  include Presto::Api
  http.map
  view.root File.expand_path './view-custom', File.dirname(__FILE__)
  view.layout("master")
  view.layouts_root(view.root + "layouts")

  view.compile :compiler_test do |action|
    true
  end

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

  def render_full_path_file

    file = "/tmp/presto-test-view-full-path-test.haml"
    File.open(file, "w") { |f| f << "full_path" }
    output = view.render_haml_view(file)
    File.unlink(file)
    output
  end

  def render_relative_path_file
    file = "relative-path/test.haml"
    view.render_haml_view(file)
  end

  def render_partial file
    view.render_partial(file)
  end

  def render_haml
    view.render_haml
  end

  def render_layout output
    view.render_layout output
  end

  def render_haml_layout output
    view.render_haml_layout output
  end

  def render_haml_action
    view.render_haml_view(:render_haml)
  end

  def render_haml_file
    view.render_haml_view("haml-file")
  end

  def opts
    "#{view.root}/#{view.layouts_root}"
  end

end


class TestOptsSetByNode < MiniTest::Unit::TestCase

  include Rack::Test::Methods
  include BasicTests

  def app
    app = Presto::App.new
    app.mount OptsSetByNode do
      # this should be override by client setup
      view.root File.expand_path './view-default', File.dirname(__FILE__)
    end
    app.map
  end

  def test_render_opts

    response = get("/opts/")
    assert_match /view\-custom\/layouts/, response.body

  end

  def test_render_full_path_file

    response = get("/render_full_path_file")
    assert_match /full_path/, response.body
  end

  def test_render_relative_path_file

    response = get("/render_relative_path_file")
    assert_match /relative\-path/, response.body
  end

end
