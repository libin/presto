require File.expand_path("lib/presto", File.dirname(__FILE__))

Gem::Specification.new do |s|

  s.name = "presto"
  s.version = Presto::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Silviu Rusu"]
  s.email = ["slivuz@gmail.com"]
  s.homepage = "http://prestorb.org"
  s.summary = "Simply Fast and Elegantly Small"
  s.description = "Presto is a web framework aimed at speed and simplicity"

  s.required_ruby_version = ">= 1.9.2"

  s.add_dependency("rack", ">= 1.2.0")

  s.require_path = "lib"
  s.files = Dir["lib/**/*"]

end
