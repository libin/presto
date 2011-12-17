module Presto
  module Test
    module Utils

      ASSERTIONS_MAP = {
            :== => :equal,
            :=~ => :match,
            :> => :gt,
            :>= => :gte,
            :< => :lt,
            :<= => :lte,
            :nil? => :nil,
            :instance_of? => :instance_of,
            :respond_to? => :respond_to,
            :is_a? => :is_a,
        }

      def proxy proxied_obj
        
        proxy, instance = Class.new, self
        proxy.class_exec do
          ASSERTIONS_MAP.each do |proxy_meth, assertion|
            self.define_singleton_method proxy_meth do |expected_value=nil|
              instance.assert(assertion, proxied_obj, expected_value, nil, proxy: true)
            end
          end
          self.define_singleton_method :refute do
            proxy = Class.new
            proxy.class_exec do
              ASSERTIONS_MAP.each do |proxy_meth, assertion|
                self.define_singleton_method proxy_meth do |expected_value=nil|
                  instance.assert(assertion, proxied_obj, expected_value, nil, :refute? => true, :proxy => true)
                end
              end
            end
            proxy
          end
          self.define_singleton_method :to_i do
            instance.proxy proxied_obj.to_i
          end
          self.define_singleton_method :to_s do
            instance.proxy proxied_obj.to_s
          end
          self.define_singleton_method :val do
            proxied_obj
          end
          self.define_singleton_method :method_missing do |*a|
            instance.proxy proxied_obj.send(*a)
          end
          class << self
            alias :not :refute
          end
        end
        proxy
      end

      def red str, ec = 0
        colorize(str, "\e[#{ ec }m\e[31m");
      end

      def green str, ec = 0
        colorize(str, "\e[#{ ec }m\e[32m");
      end

      def yellow str, ec = 0
        colorize(str, "\e[#{ ec }m\e[33m");
      end

      def blue str, ec = 0
        colorize(str, "\e[#{ ec }m\e[34m");
      end

      def magenta str, ec = 0
        colorize(str, "\e[#{ ec }m\e[35m");
      end

      def cyan str, ec = 0
        colorize(str, "\e[#{ ec }m\e[36m");
      end

      def white str, ec = 0
        colorize(str, "\e[#{ ec }m\e[37m");
      end

      def colorize(text, color_code)
        "#{color_code}#{text}\e[0m"
      end
    end

  end
end
