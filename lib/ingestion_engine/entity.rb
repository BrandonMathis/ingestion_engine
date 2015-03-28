module IngestionEngine
  class Entity
    attr_reader :headers, :row
    attr_accessor :object

    class << self
      attr_accessor :computed_attrs
    end

    def initialize(row)
      @row = row
    end

    def ingest_as(klass)
      self.object = klass.new(row.to_hash)
      self.class.computed_attrs.each do |attr|
        self.object.send("#{attr}=", self.send(attr))
      end
      self.object
    end

    def self.computed_attrs(*attrs)
      (@computed_attrs ||= []).concat attrs
    end
  end
end
