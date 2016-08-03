require "rabotnik/version"
require 'securerandom'

module Rabotnik
  class App
    def handle_command(command)
      event = TodoCaptured.new(todo_id: SecureRandom.uuid, text: command.text)
      Result.new([event], nil)
    end
  end

  Result = Struct.new(:events, :errors)

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
