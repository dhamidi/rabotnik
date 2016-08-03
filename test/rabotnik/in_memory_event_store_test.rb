require 'test_helper'
require 'rabotnik/event_store_test'

class Rabotnik::InMemoryEventStoreTest < Minitest::Test
  def event_store
    Rabotnik::InMemoryEventStore.new
  end

  include EventStoreTest
end
