module IngestionEngine
  class Reporter
    attr_reader :entities, :headers

    def initialize(entities, headers)
      @entities = entities
      @headers = headers
    end

    def log(&block)
      File.open('invalid.csv', 'w') do |f|
        f.puts (headers + ['errors']).join(',')
        entities.each do |entity|
          msg = yield(entity)
          values = headers.map{ |header| entity.send(header) }
          f.puts (values + [msg.gsub(/,/, '')]).join(', ')
        end
      end
    end
  end
end
