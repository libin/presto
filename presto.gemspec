require File.expand_path("lib/presto", File.dirname(__FILE__))

Gem::Specification.new do |s|

  s.name = "presto"
  s.version = Presto::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Silviu Rusu"]
  s.email = ["slivuz@gmail.com"]
  s.homepage = "http://prestorb.github.com/"
  s.summary = "Simply Fast and Elegantly Small"
  s.description = "Simple framework expressing speed, tidiness and an rational set of utils"

  s.required_ruby_version = ">= 1.9.2"

  s.add_dependency("rack", ">= 1.2.0")

  s.require_path = "lib"
  s.files = Dir["lib/**/*"]

end
