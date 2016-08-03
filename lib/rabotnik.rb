require "rabotnik/version"
require 'securerandom'

module Rabotnik
  class App
    def handle_command(command)
      Result.new([TodoCaptured.new(todo_id: SecureRandom.uuid)], nil)
    end
  end

  Result = Struct.new(:events, :errors)

  class CaptureTodo
    def initialize(text:)
    end
  end

  class TodoCaptured
    attr_reader :todo_id

    def initialize(todo_id:)
      @todo_id = todo_id
    end

    def event_name; :todo_captured; end
  end
end
