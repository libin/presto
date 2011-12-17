module Presto::View
  module InternalUtils

    def context_to_args context
      scope = scope() || @node_instance || @node
      scope = context unless context.is_a?(Hash) || context.nil?
      args = [scope]
      args << context if context.is_a?(Hash)
      args
    end

    def split_path path
      path = path.to_s.strip
      ext = ::File.extname(path)
      # returning path if no extension extracted
      return [path, nil] if ext.size == 0
      [path.sub(/#{ext}$/, ""), ext.sub(".", "")]
    end

    def guess_extension engine
      ::Tilt.mappings.each_pair do |ext, engines|
        return ext if engines.include?(engine)
      end
      nil
    end

    def engine_supported? engine

      if e = ENGINES[engine]
        return e
      end

      msg = []
      msg << "#{ engine } engine not supported. Please use one of:"
      ENGINES.keys.map { |e| msg << ":#{e}" }
      raise msg.join("\n")
    end

  end
end
