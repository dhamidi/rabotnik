require 'test_helper'

class RabotnikTest < Minitest::Test
  def test_rabotnik_captures_a_todo_with_some_text
    app = Rabotnik::App.new
    capture_todo = Rabotnik::CaptureTodo.new(text: 'write tests')
    result = app.handle_command(capture_todo)
    assert_nil result.errors
    assert_equals [:todo_captured, result.events.first.name]
  end
end
