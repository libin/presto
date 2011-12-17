Basics
---

**"Would you rather Test-First or Debug-Later?"**  
Robert Martin

Presto uses **inline testing**,
meant you will can write logic and tests using same ink on same paper.

    class App

        #defining action
        def index var
            '%s %s' % [__method__, var]
        end

        #testing action
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

Labeling a test:

    node.test :action do
        label 'Testing some action'
    end


Callbacks
---

Execute a callback just before specs start:

    node.test :action do
        open do
            @page = Page.create(name: 'test page Nr %s' % rand)
        end
    end

Execute a callback after all specs finished. Executed even if there are failed specs:

    node.test :action do
        close do
            @page.destroy
        end
    end

Execute a callback before each spec:

    node.test :action do
        before do
            #some logic
        end
    end

Execute a callback after each spec. Executed even if spec failed:

    node.test :action do
        after do
            #some logic
        end
    end

Specs
---

Define a spec:

    node.test :action do
        should 'Create a page' do
        end
    end

Nested specs:

    node.test :action do
        should 'Create a page' do
            #some logic
            should 'attach created page to default author' do
                #some logic
                should 'have link to author' do
                    #some logic
                end
            end
        end
    end

Specs chain interupted at first failed spec.

HTTP Requests
---

As simple as:

    get action, any: :params
    post action, any: :params

both will return an Rack::MockResponse instance,
containig methods like #body, #status, #length etc

Reuqests returning parsed JSON beside actual response:

    get_json action, any: :params
    post_json action, any: :params

both will return an array containg  
actual response and an hash containing parsed json returned by requested action.  
second element will contain an empty hash if action returned an invalid json object.

XHR Requests:

    xhr_get action, any: :params
    xhr_post action, any: :params
    xhr_get_json action, any: :params
    xhr_post_json action, any: :params

Assertions
---

Equality:

    response.status == 200
    #or
    assert :equal, response.status, 200

    response.body == 'body'
    #or
    assert :==, response.body, 'body'
    assert :eql, response.body, 'body'
    assert :equal, response.body, 'body'

Greater than, Greater than or equal:

    response.length > 0
    #or
    assert :gt, response.length, 0
    assert :>, response.length, 0

    response.status >= 200
    #or
    assert :gte, response.status, 200
    assert :>=, response.status, 200

Less than, Less than or equal:

    response.status < 400
    #or
    assert :lt, response.status, 400
    assert :<, response.status, 400

    response.status <= 200
    #or
    assert :lte, response.status, 200
    assert :<=, response.status, 200

Match:

    response.body =~ /expected value/
    #or
    assert :=~, response.body, /expected value/
    assert :match, response.body, /expected value/

Nil:

    response.body.nil?
    #or
    assert :nil?, response.body
    assert :nil, response.body


Respond to:

    response.body.respond_to?(:to_s)
    #or
    assert :respond_to?, response.body, :to_s
    assert :respond_to, response.body, :to_s

Instance of:

    response.body.instance_of?(String)
    #or
    assert :instance_of?, response.body, String
    assert :instance_of, response.body, String

Is a:

    response.body.is_a? String
    #or
    assert :is_a?, response.body, String
    assert :is_a, response.body, String

Negations:

    response.status.not == 200
    response.status.not < 200
    response.length.not == 0
    response.body.not == 'body'
    response.body.not =~ /body/
    response.body.not.instance_of? String

    refute :equal, response.status, 200
    refute :lt, response.status, 200
    refute :equal, response.length, 0

**#body, #status and #length are proxied by default.**  
To proxify an arbitrary object, use #proxy method:

    str = proxy 'some string'

    str =='some string' #passed
    str =~ /string/     #passed
    str.length > 0      #passed
    str.length == 0     #failed

    int = proxy 1
    int == 1            #passed
    int.to_s.length > 0 #passed

Or you can just use #assert syntax:

    assert :equal, x, y
    #or
    assert :eql, x, y
    #or
    assert :==, x, y

    assert :match, x, /y/
    #or
    assert :=~, x, /y/
    etc ...

To get the original value of proxied objects, send #val:

    p response.body
    #=> #<Class:...
    p response.body.val
    "body"
