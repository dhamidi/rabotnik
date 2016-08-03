module Rabotnik
  class InMemoryEventStore
    attr_reader :version
    def initialize
      @version = 1
      @events = []
    end

    def append(event)
      @events << event
      @version = @version + 1

      self
    end

    def each(&block)
      @events.each(&block)
    end
  end
end
