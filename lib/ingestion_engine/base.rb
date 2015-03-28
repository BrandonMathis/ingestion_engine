module IngestionEngine
  class Base
    attr_reader :rows, :klass, :headers

    def initialize(klass, file)
      @klass = klass
      @rows = CSV.read(file)
      @headers = @rows.shift.map!(&:strip)
    end

    def ingest
      entities = []
      init entities
      dump_invalid entities
      save entities
    end

    private

    def init(entities)
      rows.each do |row|
        obj = klass.new
        headers.each_with_index do |header, index|
          obj.send("#{header}=", row[index].strip)
        end
        entities << obj
      end
    end

    def dump_invalid(entities)
      invalids = entities.select(&:invalid?).each do |invalid_entity|
        entities.delete(invalid_entity)
      end
      IngestionEngine::Reporter.new(invalids, headers).log do |invalid|
        invalid.errors.full_messages.to_sentence
      end
    end

    def save(entities)
      entities.each { |entity| entity.save }
    end
  end
end
