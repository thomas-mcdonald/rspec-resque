require "rspec"

module MatcherHelper
  def queue(klass)
    Resque.peek(Resque.queue_from_class(klass).to_s, 0, 0)
  end
  
  def enqueued?(klass, expected_args)
    queue(klass).any? { |entry| entry["class"].to_s == klass.to_s && entry['args'] == expected_args }
  end
end

RSpec::Matchers.define :have_queued do |*expected_args|
  extend MatcherHelper
  
  match do |actual|
    enqueued?(actual, expected_args)
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would have [#{expected_args.join(', ')}] queued"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not have [#{expected_args.join(', ')}] queued"
  end

  description do
    "have queued arguments of [#{expected_args.join(', ')}]"
  end
end

RSpec::Matchers.define :have_queue_size_of do |size|
  extend MatcherHelper

  match do |actual|
    queue(actual).size == size
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would have #{size} entries queued, but got #{queue(actual).size} instead"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not have #{size} entries queued, but got #{queue(actual).size} instead"
  end

  description do
    "have a queue size of #{size}"
  end
end