module IngestionEngine
  module Ingestable
    extend ActiveSupport::Concern

    included do
    end

    class_methods do
      def ingestable
        true
      end
    end
  end
end
