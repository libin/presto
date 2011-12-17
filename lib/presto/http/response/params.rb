module Presto
  module HTTP
    class Response

      # checking that path params corresponds to action arity.
      #
      # @return [true, false]
      def params_valid?
        min_valid = @path_params.size >= @params_min
        max_valid = @params_max ? (@path_params.size <= @params_max) : true
        min_valid && max_valid
      end

      # extracting params from given path
      #
      # @return [Array]
      def params_given path
        path.split('/').map { |s| s if s.size > 0 }.compact
      end

      # determines the min and max number of params accepted, based on action arity.
      # see #params_extracted for arity.
      #
      # @example
      #    http.map "/"
      #
      #    def method arg1, arg2                  # def method arg, *args
      #    served URLs:                           # served URLs:
      #    - /method/some-arg/some-another-arg    # - /method/at-least-one-arg
      #                                           # - /method/one/or/more/args
      #    def method arg1 = nil, arg2            #
      #    served URLs:                           # def method arg = nil, *args
      #    - /method/some-arg/some-another-arg    # served URLs:
      #                                           # - /method/
      #    def method arg1, arg2 = nil            # - /method/any/number/of/args
      #    served URLs:                           #
      #    - /method/some-arg/                    # def method arg, *args, last
      #    - /method/some-arg/some-another-arg    # served URLs:
      #                                           # - /method/at-least/two-args
      #    def method *args                       # - /method/two/or/more/args
      #    served URLs:                           #
      #    - /method/                             # def method arg = nil, *args, last
      #    - /method/any/number/of/args           # served URLs:
      #                                           # - /method/at-least/one-arg
      #    def method *args, arg                  # - /method/one/or/more/args
      #    served URLs:                           #
      #    - /method/at-least-one-arg
      #    - /method/one/or/more/args
      #
      # @return [Array]
      def params_required

        min, max = 0, @action_params.size

        unlimited = false
        @action_params.each_with_index do |setup, i|

          increment = setup[0] == :req ? true : false

          if param = @action_params.values_at(i+1)[0]
            increment = true if param[0] == :req
          end

          if setup[0] == :rest
            increment = false
            unlimited = true
          end

          min += 1 if increment
        end
        max = nil if unlimited
        [min, max]
      end

      # extracting action arity
      #
      # @return [Array]
      def params_extracted
        @node_instance.method(@action).parameters
      end

    end
  end
end
