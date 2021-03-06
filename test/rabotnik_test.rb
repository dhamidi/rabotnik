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

  def test_rabotnik_capturing_a_todo_records_the_text_of_the_todo
    app = Rabotnik::App.new
    capture_todo = Rabotnik::CaptureTodo.new(text: 'write tests')
    result = app.handle_command(capture_todo)

    assert_equal('write tests', result.events.first.text)
  end

  def test_rabotnik_marking_a_todo_as_completed_fails_if_todo_has_not_been_captured
    app = Rabotnik::App.new
    mark_as_completed = Rabotnik::MarkTodoAsCompleted.new(todo_id: '1')
    result = app.handle_command(mark_as_completed)

    assert_equal([:todo_not_found], result.errors)
  end

  def test_rabotnik_marking_a_todo_as_completed_returns_event_if_todo_has_been_captured_before
    event_store = Rabotnik::InMemoryEventStore.new

    todo_id = "47b4851f-19d0-4f88-b8e5-e921bcd890c2"
    captured = Rabotnik::TodoCaptured.new(
      todo_id: todo_id,
      text: 'test',
    )
    event_store.append(captured)

    app = Rabotnik::App.new(event_store: event_store)

    mark_as_completed = Rabotnik::MarkTodoAsCompleted.new(todo_id: todo_id)

    result = app.handle_command(mark_as_completed)

    assert_nil result.errors

    completed = result.events.first
    assert_equal :todo_marked_as_completed, completed.event_name
    assert_equal todo_id, completed.todo_id
  end

  def test_rabotnik_query_todos_lists_all_todos
    app = Rabotnik::App.new
    app.handle_command(Rabotnik::CaptureTodo.new(text: 'a todo'))
    app.handle_command(Rabotnik::CaptureTodo.new(text: 'another todo'))
    todos = app.query(:todos)

    refute_nil(todos, "No todos returned")
    assert_equal(['a todo', 'another todo'], todos.all.map(&:text))
  end

  def test_rabotnik_query_todos_marks_completed_todos
    app = Rabotnik::App.new
    app.handle_command(Rabotnik::CaptureTodo.new(text: 'a todo'))
    app.handle_command(Rabotnik::CaptureTodo.new(text: 'another todo'))
    todos = app.query(:todos)
    to_complete = todos.all.first
    app.handle_command(Rabotnik::MarkTodoAsCompleted.new(todo_id: to_complete.id))

    assert todos.find_by_id(to_complete.id).completed?
  end

  def test_rabotnik_handle_command_stores_events_in_event_store
    event_store = Rabotnik::InMemoryEventStore.new
    app = Rabotnik::App.new(event_store: event_store)

    app.handle_command(Rabotnik::CaptureTodo.new(text: 'a todo'))

    seen = []
    event_store.each {|event| seen << event }
    assert_equal(['a todo'], seen.map(&:text))
  end
end
