module BasicTests
  
  def test_render

    response = get( "/render/" )
    assert_match /render/, response.body

  end

  def test_render_with_params

    response = get( "/render/id/?id=test_render_with_params" )
    assert_match /render\.xhtml/m, response.body
    assert_match /id.*test_render_with_params/m, response.body

  end

  def test_render_with_params_and_layout

    response = get( "/render_with_layout/id/?id=test_render_with_params_and_layout" )
    assert_match /header.*render_with_layout.*footer/m, response.body
    assert_match /id.*test_render_with_params_and_layout/m, response.body

  end

  def test_render_action

    response = get( "/render_action/id/?id=render_action" )
    assert_match /id.*render_action/m, response.body
  end

  def test_render_file

    response = get( "/render_file/file/?id=render_file" )
    assert_match /file/, response.body
    assert_match /id.*render_file/m, response.body
  end

  def test_render_haml

    response = get( "/render_haml" )
    assert_match /render_haml/, response.body
  end

  def test_render_haml_action

    response = get( "/render_haml_action" )
    assert_match /render_haml/, response.body
  end

  def test_render_haml_file

    response = get( "/render_haml_file" )
    assert_match /haml\-file/, response.body
  end

  def test_render_partial
    response = get( "/render_partial/partial" )
    assert_equal "partial", response.body.strip
  end

  def test_render_layout
    response = get( "/render_layout/output" )
    assert_match /header.*output.*footer/m, response.body
  end

  def test_render_haml_layout
    response = get( "/render_haml_layout/output" )
    assert_match /haml\-header.*output.*haml\-footer/m, response.body
  end

  def test_compiler
    rsp = get '/compiler_test'
    assert_equal rsp.body, 'compiler_test'
  end

end
