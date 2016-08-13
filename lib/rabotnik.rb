require "rabotnik/version"
require 'securerandom'

module Rabotnik
  class App
    def initialize(event_store: InMemoryEventStore.new)
      @todos = Views::Todos.new
      @event_store = event_store
    end

    def handle_command(command)
      result = command.execute
      result.events.each do |event|
        @event_store.append event
        @todos.handle_event event
      end
      result
    end

    def query(view)
      @todos
    end
  end

  Result = Struct.new(:events, :errors)

  module Views
    class Todos
      Todo = Struct.new(:text)

      attr_reader :all

      def initialize
        @all = []
      end

      def handle_event(event)
        @all << Todo.new(event.text)
      end
    end
  end

  class CaptureTodo
    attr_reader :text
    def initialize(text:)
      @text = text
    end

    def execute
      Result.new([TodoCaptured.new(todo_id: SecureRandom.uuid,
                                   text: text)],
                 nil)
    end
  end

  class TodoCaptured
    attr_reader :todo_id, :text

    def initialize(todo_id:,text:)
      @todo_id = todo_id
      @text = text
    end

    def event_name; :todo_captured; end
  end

  class MarkTodoAsCompleted
    attr_reader :todo_id
    def initialize(todo_id:)
      @todo_id = todo_id
    end

    def execute
      Result.new([], [:todo_not_found])
    end
  end
end

require 'rabotnik/in_memory_event_store'
