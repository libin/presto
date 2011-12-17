**Introducing Presto - a Simple framework expressing speed, tidiness and an rational set of utils**

Motto
---

**Simply Fast and Elegantly Small**

Speed
---

**The main idea behind Presto is to have a wrapper around Rack that adds as low overhead as possible.**

Currently, it adds only about 25%-30% of overhead.  
So if Rack performs at around 6000 requests per second,  
Presto will fairly perform at around 4000 requests per second.

Tidy
---

**Presto tries to keep things organized and clean.**

It adds only 3 methods to classes that include Presto::Api, i.e. nodes:

*   http
*   view
*   node

This way, HTTP methods will reside under #http, rendering methods under #view
and Presto related methods under #node.

    # map the node
    http.map '/path'

    # HTTP params
    http.params

    # set templates path
    view.root '/some/path'

    # render action
    view.render

    # write a test
    node.test :some_action do
    end

Configurability
---

With Presto it is possible to configure multiple nodes at once and each node in part.

    module Admin
        class Pages
            include Presto::Api
            http.map
        end
        class News
            include Presto::Api
            http.map :news
            http.use Rack::ShowExceptions
            view.engine :Haml
        end
    end

    app = Presto::App.new
    app.mount Admin, '/cms' do
        http.use Rack::CommonLogger
        view.engine :Erubis
    end
    # Pages will serve "/cms" path, render Erubis templates and use Rack::CommonLogger middleware.
    # News will serve "/cms/news" path, render Haml templates and use Rack::CommonLogger + http.use Rack::ShowExceptions middlewares

Views
---

Thanks to Tilt, Presto supports multiple rendering engines and a handy Api to render actions or files.

    view.root '/path/to/templates'

    def content
        view.render  # will render '/path/to/templates.rhtml', with layout
        view.render_partial  # will render '/path/to/templates.rhtml', without layout
        view.render_view 'some-file' # will render '/path/to/some-file.rhtml', with layout
        view.render_view '/full/path/to/some/file.erb'
        view.render_haml_view '/full/path/to/some/file' # will render '/full/path/to/some/file.haml'
        view.render_layout 'some string' # will render layout, yelding 'some string' as output
    end

**Performance**

Presto allow to compile templates and just render them later.

    # instruct Presto to compile all templates
    view.compile { true }

    # instruct Presto to compile only templates for #static action
    view.compile(:static) { true }
    
    # instruct Presto to compile templates and update cache as needed
    view.compile do
        :update if http.params['update-compiler']
    end

Cache
---

With Presto is dead easy to cache entire actions and manage cache at a glance.

    # cache all actions
    http.cache { true }

    # cache all actions and update cache as needed
    http.cache do
        :update if http.params['update-cache']
    end

    # cache only #static action
    http.cache :static do
        cache = true
        cache = :update if http.params['update-cache']
        cache
    end

Security
---

With Presto you can easily confine access to HTTP Api,  
so, the people who editing templates  
wont be able to read sessions / cookies / env, nor to redirect / halt / forward.  
Just read params, host, user-agent etc.

    http.before do
        http.confine
    end

It is also possible to give readonly access to sessions and cookies:

    http.before do
        http.session.confine
        http.cookies.confine
    end

Note: if you confine Api and yet need access to session/cookies,  
make sure you add session/cookies capabilities when confining:

    http.before do
        http.confine :session, :cookies
    end


Testing
---

Presto uses **inline testing**,  
meant you will can write logic and tests using same ink on same paper.

    class App

        # defining action
        def index var
            '%s %s' % [__method__, var]
        end

        # testing action
        node.test :index do
            should 'do a simple test' do
                response = get :index, :test
                response.body == 'index test'
                #=> passed
                assert :equal, 'index test', response.body
                #=> passed
            end
        end
    end

    # creating app
    app = Presto::App.new
    app.mount App

    # running tests
    Presto::Test.run app


Feedback
---

Feel free to submit any issues at https://github.com/slivu/presto/issues  
and ask any questions at **#presto.rb** IRC channel on irc.freenode.net

License
---

Copyright (c) Silviu Rusu.  
Distributed under 3-clause BSD License.
