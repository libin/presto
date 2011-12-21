module Presto
  module Test
    module Utils

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
