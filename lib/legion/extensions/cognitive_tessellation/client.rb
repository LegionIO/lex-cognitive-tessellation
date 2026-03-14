# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveTessellation
      class Client
        include Runners::CognitiveTessellation

        def initialize
          @default_engine = Helpers::TessellationEngine.new
        end
      end
    end
  end
end
