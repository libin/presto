
Quickstart
---

**Ready**

    class MyApp
        include Presto::Api
        http.map
    end

**Set**

    app = Presto::App.new
    app.mount MyApp

**Go**

    run app.map

Routes
---

    class App

        include Presto::Api
        http.map # only mapped nodes will respond to http requests

        def index
        end
        # /
        # /index
        
        def edit id
        end
        # /edit/someID

        def item id = nil
        end
        # /item
        # /item/someID

        def save id, column = nil
        end
        # /save/someID
        # /save/someID/someColumn
    end

If there are multiple controllers on same root, use partition config.

**Root** defined at mount will be used by all nodes under mounted namespace.

    module MyApp
        class Pages
            include Presto::Api
            http.map
        end
        class News
            include Presto::Api
            http.map :news
        end
    end

    app = Presto::App.new

    app.mount MyApp, '/'
    # Pages will serve "/"
    # News will serve "/news"

    app.mount MyApp, '/cms'
    # Pages will serve "/cms"
    # News will serve "/cms/news"

**Path Translating Rules**

By default, Presto will translate:

    ____ (4 underscores) to . (period)
    ___  (3 underscores) to - (hyphen)
    __   (2 underscores) to / (slash)

To override this, use *http.path_rules*

    http.path_rules "__" => "/",
                    "___" => "-",
                    "__dot__" => ".",
                    "__coma__" => ","
                   
    def some_page__dot__html
    end
    # /some_page.html

**Canonical Routes**

Make a node to respond to multiple roots.

    class Cms
        http.map
        http.canonical '/cms', '/pages'
    end
    
Now Cms will respond to any of:

    "/"
    "/cms"
    "/pages"

**Getting routes**

    http.route :index, key: 'val'
    #=> /index/?key=val

    http.route :index, 1, 2, key: 'val'
    #=> /index/1/2/?key=val

    App.http.route :edit, 1
    #=> /edit/1


Forwarding conrol
---

Allow to stop execution of current action or hook and pass control to an arbitrary action.

Pass control to an action on same node:

    http.fwd :action

Pass control to an action on inner node:

    http.fwd :action, SomeNode

If block passed, it will be executed just before leaving current scope.  
Block receives reference to current ENV as first argument and may update it accordingly.

Also, if second argument is an valid Presto node, control will be passed to it.

HTTP Aliases
---

Presto adding 3 methods to nodes:

    - http
    - view
    - node

If you consider any of this should be reserved by your app  
or you need some action to respond to multiple routes, simply add an alias:

    http.alias :method_name, :route1, :route1, :etc

Making app to respond to /http/ route:

    http.alias :presto_http, :http

    def presto_http
    end

Making app to return same content on 4 different routes:

    http.alias :register, :create_account, :new_account, :signup

    def register
    end

Builtin File Server
---

Allow to serve static files from an arbitrary folder.

Lets say there are an folder like this:

    $>ls /full/path/to/served/files/
    $>logo.jpg theme.css master.js

then simply create a Presto node:

    class FileServer
        include Presto::Api
        http.map '/file-server'
        http.file_server '/full/path/to/served/files/'
    end

and voila - files are served by your app at:

    /file-server/logo.jpg
    /file-server/theme.css
    /file-server/master.js

That's of course with condition that web server does not serve them before your app.  
And such this is the case in most cases, you should modify the ENV sent to your file server.

    class FileServer
        include Presto::Api
        http.map '/file-server'
        http.file_server '/full/path/to/served/files/' do |env|
            env["PATH_INFO"] = env["PATH_INFO"].sub(/\.myFS$/i, "")
        end
    end

now the files are served by your app at:

    /file-server/logo.jpg.myFS
    /file-server/theme.css.myFS
    /file-server/master.js.myFS


Content-Type
---

Default content type is text/html

**Set xml content type for all actions**

    http.content_type do
        http.mime_type '.xml'
    end
    #or
    http.provide do
        http.mime_type '.xml'
    end
    
**Set xml content type for all actions, with some exceptions**

    http.content_type do |action|
        http.mime_type action == :html || http.path =~ /\.html$/ ? '.html' : '.xml'
    end

**Also available as partition config**

    module RSS
        class Pages
            include Presto::Api
            http.map
        end
        class News
            include Presto::Api
            http.map :news
        end
    end

    app = Presto::App.new
    app.mount RSS, '/rss' do
        http.content_type { http.mime_type('.rss') }
    end
    # now any action under Pages and News will return "application/rss+xml" content type

Hooks
---

If no args provided, hooks will be executed before/after any action:

    http.before do |action|
    end

Execute a hook only before #index and #edit:

    http.before :index, :edit do |action, *args|
    end

Execute a hook only after #save:

    http.after :save do |action|
    end

**Normally, any hook adds overhead, so keep them tight!**

Cookies
---

    http.cookies['key'] = 'val'
    http.cookies['key']
    #=> :val

    http.cookies.delete 'key'
    http.cookies['key']
    #=> nil

Session
---

    http.session['key'] = :val
    http.session['key']
    #=> :val

    http.session.delete 'key'
    http.session['key']
    #=> nil

**Flash**

    http.flash[:alert] = 'Item updated successfully'
    http.flash[:alert]
    #=> 'Item updated successfully'
    http.flash[:alert]
    #=> nil

Readonly Session / Cookies
---

**Allow to make session/cookies readonly.**

Lock session for all actions:

    http.before do
        http.session.confine
    end

Lock session selectively:

    http.before :render do
        http.session.confine
    end

Lock session and cookies for unauthorized users:

    http.before do
        unless http.user
            http.session.confine
            http.cookies.confine
        end
    end


Sandbox
---

**Allow to fine tune access to HTTP Api.**

Normally, all capabilities enabled by default.
Sandbox allow to limit them to:

*  flash
*  user
*  params
*  get_params
*  post_params
*  scheme
*  host
*  host_with_port
*  port
*  path_info
*  request_method
*  query_string
*  body
*  content_length
*  content_type
*  media_type
*  content_charset
*  get?
*  head?
*  options?
*  post?
*  put?
*  xhr?
*  trace?
*  form_data?
*  parseable_data?
*  referer
*  referrer
*  user_agent
*  url
*  path
*  fullpath
*  accept_encoding
*  ip

Other capabilities can be added when sandbox defined.

Generic sandox for all actions:

    http.before do
        http.confine
    end

Generic sandox for #render_page action:

    http.before :render_page do
        http.confine
    end

Custom sandbox for #order action:

    http.before :order do
        http.confine :redirect, :session, :cookies
    end



Halt
---

Stop executing any action or hook and send response to browser:

    def register email
        if Users.first(email: email)
            http.halt '%s already exists in our db.' % http.escape_html(email)
        end
    end

Second argument may contain status code and any optional headers:

    http.before :edit do
        unless (@id = http.params['id'].to_i) > 0
            http.halt 'Wrong item id', status: 500
        end
    end

Custom content type:

    def theme____css
        http.halt File.read('/path/to/theme.css'), 'Content-Type' => http.mime_type('.css')
    end

If first argument is an array, it is treated as a Rack response:

    http.halt [200, {'X-Accel-Redirect' => '/some/file'}, []]
    # second argument ignored in this case

Redirect
---

Redirect right away:

    http.redirect http.route(:index)
    http.redirect '/path'

Redirect after action(and hooks, if any) successfully finished:

    http.delayed_redirect '/some/path'

Reload page with original GET params:

    http.reload

Reload page using custom GET params:

    http.reload var: 'val'

*Note: reload actually behaves as redirect,*  
*so it would interupt any action/hook execution and reload the page right away.*

Auth
---

**Basic Auth:**

    http.auth do |user, pass|
        [user, pass] == ['admin', 'some really secret password']
    end

**Digest Auth:**

    http.auth type: :digest, realm: 'AccessRestricted' do |user|
        {
            'admin' => 'MD5 hash of user + realm + password'
        }[user]
    end

Plain text password(strongly discouraged):

    http.auth type: :digest, plain: true do |user|
        {
            'admin' => 'some password'
        }[user]
    end

Force browser to update nonce each hour:

    http.auth type: :digest, nonce_ttl: 3600 do |user|
        {
            'admin' => 'some password'
        }[user]
    end

**HTML Auth:**

*Note: basic and digest keeps credentials in browser and validate them at each HTTP requaest.*  
*Html auth instead does not have a default store, so you'll have to provide one.*  
*You can keep authorized user into sessions/cookies or any request-persistent store.*

    http.auth type: :html do |user, pass|
        http.session[:auth] ||= [user,pass] == ['user', 'password'] && user
    end
    # http.session[:auth] will store authorized user,
    # however, it will also be available by http.user

**Custom HTML Auth:**

    http.auth type: :html, body: view.render(:some_action) do |user, pass|
        http.session[:auth] ||= [user,pass] == ['user', 'password'] && user
    end

Please make sure your template has a form containing following input tags:

    - username
    - password
    
and a submit tag with name:

    - presto-authorization-html

**Also available as partition config**

    module Admin
        class Pages
            include Presto::Api
            http.map
        end
        class News
            include Presto::Api
            http.map :news
        end
    end

    app = Presto::App.new
    app.mount Admin, '/admin' do
        http.auth do |user, pass|
            [user, pass] == ['admin', 'some really secret password']
        end
    end
    # now any action under Pages and News will require authorization

Cache
---

Cache block will be executed on each request, just before action executed.

*   if cache block returns true [Boolean], current action will use cache.
*   if cache block returns :update [Symbol], cache for current action will be updated.

Otherwise, action will be executed.

If no args provided, all actions will use same cache logic:

    http.cache do
        true
    end

Cache only #content action, and ignore cache if "fresh" param found in GET or POST:

    http.cache :content do
        true unless http.params['fresh']
    end

Updating / Rebuilding cache:

    http.cache do
        :update if http.params['rebuild_cache']
    end

Also available as partition config

**Pool**

By default, cache stored in memory.  
It is good and fast for content which fits in available RAM.  

Using MongoDB as cache pool:

    class Pages
        db = Mongo::Conection.new.db('cache')
        http.cache_pool Presto::Cache::MongoDB.new(db)
    end

Also available as partition config

    module Cms
        class Pages
            include Presto::Api
            http.map
        end
        class News
            include Presto::Api
            http.map :news
        end
    end

    app = Presto::App.new
    app.mount Cms do
        db = Mongo::Conection.new.db('cache')
        http.cache_pool Presto::Cache::MongoDB.new(db)
    end
    # now Pages and News will use mongodb cache pool

Rewriting
---

Redirecting all .htm pages to .html:

    http.before do
        if m = http.path.match(/^(.*)\.htm$/)[1]
            http.redirect '%s.html' % m
        end
    end

HTTP to HTTPS:

    # http to https
    http.before do
      if http.scheme == 'http'
        http.redirect 'https://' + http.host_with_port + http.fullpath
      end
    end


Internal Browser
---

    class App

        include Presto::Api
        http.map

        def index
            [http.request_method, http.xhr?, http.get(:snippet)]
        end

        def snippet
            [__method__, http.request_method].join('/')
        end
    end

    App.http.get(:index)
    #=> ['GET', false, 'snippet/GET']

    App.http.xhr_get(:index)
    #=> ['GET', true, 'snippet/GET']

    App.http.post(:index)
    #=> ['POST', false, 'snippet/POST']

    App.http.xhr_post(:index)
    #=> ['POST', true, , 'snippet/POST']


Error handling
---

Provide error code and block to be executed when error raising:

    http.error 404 do
        view.render :error_404
    end

    http.error 500 do |full_exception|
        @exception = full_exception
        view.render :exception
    end

Also available as partition config

Rack Middleware
---
As usual

    http.use SomeMiddleware, with: 'some opts'

Also available as partition config
