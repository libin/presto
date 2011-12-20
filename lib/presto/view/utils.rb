module Presto::View
  module InternalUtils

    def split_path path
      path = path.to_s.strip
      ext = ::File.extname(path)
      # returning path if no extension extracted
      return [path, nil] if ext.size == 0
      [path.sub(/#{ext}$/, ""), ext.sub(".", "")]
    end

    def guess_layout ext = nil
      if layout_name = layout[@action] || layout['*']
        '%s/%s.%s' % [layouts_root(), layout_name, ext || ext() || guess_extension(engine())]
      end
    end

    def guess_path path_or_action, ext

      if @node && map = @node.node.map[path_or_action]

        # 1st param is an action.
        path = map[:path].sub(/^\/+/, '')

      else
        # splitting given path into path and extension
        path, extension = split_path(path_or_action)
        # overriding given ext with file ext
        ext = extension if extension && Tilt.registered?(extension)
      end

      if path[0] == '/'
        '%s.%s' % [path, ext]
      else
        '%s/%s.%s' % [path(), path, ext]
      end
    end

    def guess_scope_and_context *scope_and_or_context
      scope, context = scope() || @node_instance || @node, Hash.new
      scope_and_or_context.each { |a| a.is_a?(Hash) ? context.update(a) : scope = a }
      [scope, context]
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
