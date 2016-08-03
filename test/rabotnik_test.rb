require 'test_helper'

class RabotnikTest < Minitest::Test
  def test_rabotnik_captures_a_todo_with_some_text
    app = Rabotnik::App.new
    capture_todo = Rabotnik::CaptureTodo.new(text: 'write tests')
    result = app.handle_command(capture_todo)
    assert_nil result.errors
    assert_equal(:todo_captured, result.events.first.event_name)
  end

  def test_rabotnik_capturing_a_todo_assigns_a_random_id_to_the_todo
    app = Rabotnik::App.new
    capture_todo = Rabotnik::CaptureTodo.new(text: 'write tests')
    result = app.handle_command(capture_todo)
    first_id = result.events.first.todo_id
    result = app.handle_command(capture_todo)
    second_id = result.events.first.todo_id

    refute_equal(first_id, second_id, "todo IDs needs to differ")
  end
end
