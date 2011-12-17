module Presto
  module HTTP
    class Response

      def hooks hooks
        [
            hooks["*"],
            hooks[@action],
        ].compact.uniq
      end
    end
  end
end
