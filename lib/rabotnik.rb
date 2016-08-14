require "rabotnik/version"
require 'securerandom'

module Rabotnik
  class App
    def initialize(event_store: InMemoryEventStore.new)
      @todos = Views::Todos.new
      @event_store = event_store

      replay_history!
    end

    def handle_command(command)
      result = command.execute(self)
      result.events.each do |event|
        @event_store.append event
        @todos.handle_event event
      end
      result
    end

    def query(view)
      @todos
    end

    private

    def replay_history!
      @event_store.each do |event|
        @todos.handle_event event
      end
    end
  end

  Result = Struct.new(:events, :errors)

  module Views
    class Todos
      Todo = Struct.new(:id, :text, :state) do
        def completed?
          state == :completed
        end
      end

      attr_reader :all

      def initialize
        @all = []
      end

      def find_by_id(id)
        @all.find { |todo| todo.id == id }
      end

      def handle_event(event)
        case event.event_name
        when :todo_captured
          @all << Todo.new(event.todo_id, event.text)
        when :todo_marked_as_completed
          find_by_id(event.todo_id).state = :completed
        end
      end
    end
  end

  class CaptureTodo
    attr_reader :text
    def initialize(text:)
      @text = text
    end

    def execute(application)
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

    def execute(application)
      todo = application.query(:todos).find_by_id(todo_id)

      if todo
        Result.new([TodoMarkedAsCompleted.new(todo_id: todo_id)],
                   nil)
      else
        Result.new([], [:todo_not_found])
      end
    end
  end

  class TodoMarkedAsCompleted
    attr_reader :todo_id

    def initialize(todo_id:)
      @todo_id = todo_id
    end

    def event_name; :todo_marked_as_completed; end
  end
end

require 'rabotnik/in_memory_event_store'
