require ::File.expand_path("_init", ::File.dirname(__FILE__))

module Admin

  class Admin
    include Presto::Api
    http.map "/admin/"

    def index
      http.user
    end
  end

  class Articles
    include Presto::Api
    http.map "/admin/articles"

    def index
      http.user
    end
  end

  class News
    include Presto::Api
    http.map "/admin/news"

    http.auth do |u, p|
      [u, p] == ["u", "p"]
    end

    http.auth :edit do |u,p|
      [u, p] == ["a", "p"]
    end

    def index
      http.user
    end

    def edit
      http.user
    end

  end

end

module App

  class Controller

    include Presto::Api
    http.map "/"

    http.auth html: true do |user, pass|
      user == "user" && pass == "up"
    end

    http.auth :edit do |user, pass|
      user == "admin" && pass == "ap"
    end

    def index
      http.user
    end

    def edit
      http.user
    end

  end
end

app = Presto::App.new
app.mount App
app.mount Admin do |p|
  p.http.auth html: true do |u, p|
    [u, p] == ['root', 'rp']
  end
end
run app.map
