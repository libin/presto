module Presto
  class Node

    include ::Presto::InternalUtils

    attr_reader :namespace, :on_init, :tests

    # initializing node Api for given node.  
    # node Api will store data like:  
    # - callbacks to be executed at node initialization  
    # - node map  
    # - node's partition setup  
    # - node's tests
    #
    # @param [Class] node to store initialized Api
    def initialize node
      @node = node
      @namespace = extract_namespace @node
      @on_init = Array.new
      @tests = Hash.new
    end

    # adding a callback to be executed at node initialization.
    # 
    # @attr on_init
    # @param [Proc]
    def on_init &proc
      unless mounted? # prohibit setting callback after node mounted
        @on_init = proc if proc
      end
      @on_init
    end

    # if there are an namespace unknown to your app,
    # its nodes yet can be mounted into app.  
    # simply use node.mount
    # @example
    #    class InnerNamespace
    #      class App
    #        include Presto::Api
    #        http.map '/inner-app'
    #
    #        def some_action
    #        end
    #
    #        node.mount
    #      end
    #    end
    #    # Important! put node.mount after http.map and all actions defined.
    def mount
      partition Presto::Partition.new
      partition << @node
    end

    def mounted?
      @map
    end

    # any node is a member of some partition.
    #
    def partition partition = nil
      @partition ||= partition if partition
      @partition
    end

    # each node keeps its map in his memory.
    #
    # @attr map
    # @api private
    def map map = nil
      @map ||= map if map
      @map
    end

    # adding a new test block.
    #
    # @param [Symbol, Hash] actions_and_or_opts both optional,
    #  actions are displayed on output, allowing to know what action are tested.  
    #  if no action given, :index used.  
    #  if test is meant to be skipped, use :skip => true as second argument.
    # @param [Proc] proc
    def test *actions_and_or_opts, &proc
      unless proc
        raise '--- Tests needs an block to run ---'
      end
      actions, opts = Array.new, Hash.new
      actions_and_or_opts.map { |arg| arg.is_a?(Hash) ? opts.update(arg) : actions << arg.to_sym }
      actions = [:index] if actions.size == 0
      actions.each { |a| (@tests[a] ||= Array.new) << {opts: opts, proc: proc} }
    end

  end
end
