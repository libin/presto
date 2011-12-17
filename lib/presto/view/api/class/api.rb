module Presto
  module View
    class Api

      include SharedApi
      include Config

      # initializing the View Api.
      # if node given, initialized instance will serve as View Api for given node.  
      # otherwise, it will be used as a generic rendering Api.
      #
      # @example render a haml template, not associated to any node
      #    api = Presto::View::Api.new
      #    api.engine = :Haml
      #    api.render_view '/path/to/template.haml'
      #
      # @example render a file directly, without defining engine explicitly
      #    Presto::View::Api.new.render_haml_view '/path/to/template.haml'
      #
      def initialize node = nil
        super
        @node = node
      end

      private
      def configurable?
        @node ? (@node.node.mounted? ? false : true) : true
      end

    end
  end
end
