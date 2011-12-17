module Presto
  module HTTP
    module SharedApi

      # performing an internal GET request
      #
      # @return [String]
      def get *args, params_or_action
        Presto::Browser.new(@node).body *args, params_or_action
      end

      # performing an internal POST request
      #
      # @return [String]
      def post *args, params_or_action
        Presto::Browser.new(@node, 'POST').body *args, params_or_action
      end

      # performing an internal XMLHttpRequest GET request
      #
      # @return [String]
      def xhr_get *args, params_or_action
        Presto::Browser.new(@node, 'GET', true).body *args, params_or_action
      end

      alias :xhr :xhr_get

      # performing an internal XMLHttpRequest POST request
      #
      # @return [String]
      def xhr_post *args, params_or_action
        Presto::Browser.new(@node, 'POST', true).body *args, params_or_action
      end

    end
  end
end
