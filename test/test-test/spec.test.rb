require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestFrameworkTest

  def test_spec0
    assert_match /pass level #0 spec/, OUTPUT
    assert_match /level #0 spec passed/, OUTPUT
  end
  def test_spec1
    assert_match /pass level #1 spec/, OUTPUT
    assert_match /level #1 spec passed/, OUTPUT
  end
  def test_spec2
    assert_match /pass level #2 spec/, OUTPUT
    assert_match /level #2 spec passed/, OUTPUT
  end
  def test_spec3
    assert_match /pass level #3 spec/, OUTPUT
    assert_match /level #3 spec passed/, OUTPUT
  end
  def test_spec4
    assert_match /pass level #4 spec/, OUTPUT
    assert_match /level #4 spec passed/, OUTPUT
  end
  def test_spec5
    assert_match /pass level #5 spec/, OUTPUT
    assert_match /level #5 spec passed/, OUTPUT
  end
end
