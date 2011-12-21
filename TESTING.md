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
                t { response.body == 'index test' }
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

Assertions
---

As simple as

    response = get :index
    t { response.status == 200 } #=> pass
    t { response.status < 300 } #=> pass
    
    t { 'some string' == 'some another string' } #=> fail

In a word - test is passed if block returns a positive value.


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
