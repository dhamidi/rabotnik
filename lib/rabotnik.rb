require "rabotnik/version"
require 'securerandom'

module Rabotnik
  class App
    def initialize(event_store: InMemoryEventStore.new)
      @todos = Views::Todos.new
      @event_store = event_store
    end

    def handle_command(command)
      event = TodoCaptured.new(todo_id: SecureRandom.uuid, text: command.text)
      @event_store.append event
      @todos.handle_event event
      Result.new([event], nil)
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
  end

  class TodoCaptured
    attr_reader :todo_id, :text

    def initialize(todo_id:,text:)
      @todo_id = todo_id
      @text = text
    end

    def event_name; :todo_captured; end
  end
end

require 'rabotnik/in_memory_event_store'
