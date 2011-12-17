require "rack"

class RackApp
  def call env
    response = Rack::Response.new
    response.write "Hello World"
    response.finish
  end
end
Rack::Handler::Thin.run RackApp.new, Port: $*[0].to_i
