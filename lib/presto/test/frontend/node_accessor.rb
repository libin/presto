module Presto
  module Test
    class Frontend
      module NodeAssessor

        def http
          node.http
        end

        def view
          node.view
        end

        def admin
          node.admin
        end
      end
    end
  end
end
