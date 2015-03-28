module IngestionEngine
  class Base
    attr_reader :csv, :klass

    def initialize(klass, filepath)
      @klass = klass
      @csv = CSV.parse(
        IO.read(filepath),
        headers: true,
        header_converters: lambda { |f| f.strip },
        converters: lambda { |f| f ? f.strip : nil }
      )
    end

    def ingest(as: IngestionEngine::Entity)
      entities = init(as)
      dump_invalid entities
      save entities
    end

    private

    def init(as)
      csv.map do |row|
        as.new(row).ingest_as(klass)
      end
    end

    def dump_invalid(entities)
      invalids = entities.select(&:invalid?).each do |invalid_entity|
        entities.delete(invalid_entity)
      end
      IngestionEngine::Reporter.new(invalids, csv.headers).log do |invalid|
        invalid.errors.full_messages.to_sentence
      end
    end

    def save(entities)
      entities.each { |entity| entity.save }
    end
  end
end
