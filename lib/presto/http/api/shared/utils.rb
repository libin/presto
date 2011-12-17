module Presto
  module HTTP
    module SharedApi

      %w[
      escape
      unescape
      escape_path
      parse_query
      parse_nested_query
      normalize_params
      build_query
      build_nested_query
      escape_html
      select_best_encoding
      bytesize
      rfc2822
    ].map { |m| m.to_sym }.each do |m|
        define_method m do |*args|
          ::Rack::Utils.send(m, *args)
        end
      end

      %w[
      escape_html
      unescape_html
      escape_element
      unescape_element
      rfc1123_date
      pretty
    ].map { |m| m.to_sym }.each do |m|
        define_method m do |*args|
          ::CGI.send(m, *args)
        end
      end

      # get mime-type by extension
      #
      # @example
      #    http.mime_type '.html'  #=> "text/html"
      #    http.mime_type '.css'   #=> "text/css"
      #    http.mime_type '.js'    #=> "text/js"
      #    http.mime_type '.txt'   #=> "text/plain"
      #
      # @return [String]
      def mime_type type
        Rack::Mime.mime_type type
      end

      # builds path from given args
      #
      # @return [String]
      def build_path *args
        Presto::Utils.build_path *args
      end

    end
  end
end
