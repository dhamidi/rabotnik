require "rabotnik/version"

module Rabotnik
  class App
    def handle_command(command)
      Result.new([TodoCaptured.new], nil)
    end
  end

  Result = Struct.new(:events, :errors)

  class CaptureTodo
    def initialize(text:)
    end
  end

  class TodoCaptured
    def event_name; :todo_captured; end
  end
end
