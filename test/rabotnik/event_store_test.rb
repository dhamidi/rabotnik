require 'test_helper'

module EventStoreTest
  TestEvent = Struct.new(:event_name)

  def test_version_returns_1_for_an_empty_event_store
    assert_equal(1, event_store.version)
  end

  def test_append_increments_version_by_1
    subject = event_store
    subject.append TestEvent.new(:test)
    assert_equal(2, subject.version)
  end

  def test_each_yields_to_block_for_every_event_that_has_been_appended
    subject = event_store
    subject.append TestEvent.new(:a)
    subject.append TestEvent.new(:b)

    seen = []
    subject.each { |event| seen << event }
    assert_equal([:a, :b], seen.map(&:event_name))
  end
end
