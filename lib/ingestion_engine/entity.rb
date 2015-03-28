module IngestionEngine
  class Entity
    attr_reader :headers, :row

    def initialize(row)
      @row = row
    end

    def ingest_as(klass)
      headers = row.headers
      klass.new row.to_hash
    end

    def value_of
      row[index].strip
    end
  end
end
