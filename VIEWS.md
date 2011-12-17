**Presto make use of Tilt as interface to multiple template engines.**

For now, Presto delivered with a modified version of Tilt(as long as Tilt license permits this),  
that allow to save precompiled templates as strings.  
See https://github.com/rtomayko/tilt/pull/118  
when the pull request will be accepted,  
or Tilt will get any other way to get/use precompiled template,  
Presto will use original Tilt gem.  
Thanks to people behind Tilt  
for such a rational implementation of such a great idea.  

Configuration
---

View Api can be configured by node and by partition.  
Node config has precedence over partition config,  
so you can use partition to configure N nodes,  
and if some node in the partition should use custom config,  
simply configure the node itself.

    module Cms
        class Pages
        end
        class News
        end
        class Articles
            view.root '/path/to/articles/templates'
            view.engine :Haml
        end
    end

    app = Presto::App.new
    app.mount Cms do
        view.root '/some/path'
        view.engine :Erubis
    end
    # Pages and News will render templates from "/some/path" uging Erubis
    # Articles instead, will render Haml templates from "/path/to/articles/templates"

**Any of configurations below can be set by both node and partition.**

view.engine
---
engine to be used and optionally template extension

    view.engine :Erubis

Templates extenstion are guessed from engine given,  
however it is possible to explicitly define extension:

    view.engine :Erubis, :rhtml
    view.engine :Haml, :hml

or by using **view.ext**:

    view.ext :rhtml

Partition config:

    app.mount App do
        
        view.engine :Erubis, :rhtml
        # or
        view.engine :Erubis
        view.ext :rhtml

    end

view.root
---
absolute path to folder containing templates

    http.map '/pages'

    view.engine :Haml
    view.root '/path/to/templates'
    
    def content
        view.render # will render "/path/to/templates/pages/content.haml"
    end

view.layout
---
template name to be used as layout

    view.layout :default

view.layouts_root
---
absolute path where layouts resides

    view.layouts_root '/path/to/templates/layouts'
    # or
    view.root '/path/to/templates'
    view.layouts_root view.root + 'layouts'

view.scope
---
scope to be used when template rendered

By default, current scope used, however, if you have to render some untrusted views,
you would like to confine them to a custom scope.

    class RenderScope
        def some_action
        end
    end
    view.scope RenderScope.new

view.enable_compiler
---
compile once, render N times

For most apps, most expensive operations are fs operations  
and template compilation. It is possible to avoid these operations  
by storing compiled templates in memory and just render them later.

This method allow to enable compiler for all or just some actions.  
Actions should be passed one by one as arguments.  
If no args passed, all actions will use compiler.

**Compiler behavior are determined by given block.**

* if block returns any positive value, compiled template will be used.
* if block returns :update [Symbol], compiled template will be updated and used.

**Note! Compiler will work only if block given.**

Example: compile templates for all actions

    view.compile { true }

Example: compile templates only for #summary and #content

    view.compile(:summary, :content) { true }

Example: update cache as needed

    view.compile do
        :update if http.params['update-compiler']
    end

    view.compile do |action|
        :update if action == :content && http.params['update-content']
    end


view.compiler_pool
---

By default, compiled templates are kept in memory.  
This option allow to use custom pool.

Exxample: using MongoDB pool for compiled templates

    db = Mongo::Connection.new.db('compiler-pool')
    view.compiler_pool Presto::Cache::MongoDB.new(db)

Rendering
---

Render current action:

    def register
        view.render
    end

Render an action by name, with layout:

    def register_with_ad
        view.render_view(:register) + 'some ad maybe'
    end

Render an view file, with layout:

    def register_with_fun
        view.render_view('/full/path/to/fun')
    end

Render current action partially, i.e. without layout:

    def partial
        view.render_partial
    end

Render an partial by action name:

    def concat_partials
        view.render_partial(:partial) + view.render_partial(:top_ad)
    end

Render an partial by path:

    def top_ad
        view.render_partial '/full/path/to/file'
    end
