SONATA_PROFILER_ENABLED = true
require "../../lib/presto"

class App

  include Presto::Api
  
  http.map
  http.use Rack::ShowExceptions if $*[1]

  def index
    "Hello World"
  end
end

app = Presto::App.new
app.mount App
Rack::Handler::Thin.run app.map, Port: $*[0].to_i
