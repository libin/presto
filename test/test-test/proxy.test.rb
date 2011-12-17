require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestFrameworkTest

  %w[strings fixnums].each do |spec|
    define_method :"test_proxify_#{spec}" do
      assert_match 'proxify %s passed' % spec, OUTPUT
    end
  end

end
