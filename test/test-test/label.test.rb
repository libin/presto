require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestFrameworkTest

  def test_label
    assert_match /Testing #index/, OUTPUT
  end
end
