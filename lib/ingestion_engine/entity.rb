module IngestionEngine
  class Entity
    attr_reader :headers, :row

    def initialize(headers, row)
      @headers = headers
      @row = row
    end

    def ingest_as(klass)
      obj = klass.new
      headers.each_with_index do |header, index|
        obj.send("#{header}=", row[index].strip)
      end
      obj
    end
  end
end
