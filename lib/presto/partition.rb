module Presto
  class Partition

    include Presto::InternalUtils

    attr_reader :root, :nodes, :http, :view

    # creating an app partition from given namespace.  
    # this will select all nodes in given namespace
    # and update their partition, setting it to one initialized here.
    # 
    # given block will receive partition object as first arg and will can configure it.  
    # nodes under partition will use partition's setup beside own internal setup.
    # @example
    #    app = Presto::App.new
    #    app.mount SomeNamespace do |partition|
    #      # here is where partition is to be configured ...
    #      # locking all nodes
    #      partition.http.auth {|u,p| [u,p] == ['admin', 'ssp']}
    #      # middleware to be used by all nodes
    #      partition.http.use SomeMiddleware
    #      # defining view root for all nodes
    #      partition.view.root '/some/path'
    #      # etc
    #    end
    #
    # @param [Module, Class, nil] namespace containing Presto nodes.
    # @param [String, Symbol] root for Presto nodes under given namespace.
    # @yield [partition] used to configure given namespace.
    # @return the map of given namespace.
    def initialize namespace = nil, root = nil, &proc

      @namespace = namespace
      @root = rootify_path(root).gsub(/\/+$/, '')
      @http = HTTP::Partition.new self
      @view = View::Partition.new self
      @nodes = Array.new

      # configuring partition if block given
      self.instance_exec(self, &proc) if proc
      # prohibit any later updates to configs
      @configured = true

      # add to partition all valid Presto nodes found under given namespace.
      # "valid" meant rooted nodes, i.e. ones that defined http.map
      if @namespace
        Presto.nodes.select { |n| n.node.namespace.to_s =~ /^#{@namespace}/ }.each do |node|
          node.node.partition self
          @nodes << node
        end
        # map all nodes found under given namespace
        map
      end
    end

    def configured?
      @configured
    end

    # add an arbitrary node to current partition.
    #
    # @param [Class] node
    def << node
      @nodes << node
      # remapping nodes
      map
    end

    private
    # update partition's nodes map
    def map
      mapper = Presto::Mapper.new
      @nodes.select { |n| n.http.root }.uniq.each do |node|
        node.node.map mapper.map(self, node)
      end
    end

  end
end
