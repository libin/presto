require ::File.expand_path("_init", ::File.dirname(__FILE__))

class TestFrameworkTest

  %w[equal match gt gte lt lte nil instance_of is_a respond_to].each do |spec|
    define_method :"test_assert__#{spec}" do
      assert_match '%s passed' % spec, OUTPUT
    end
  end

end
