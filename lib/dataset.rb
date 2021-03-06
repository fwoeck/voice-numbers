require './lib/call_details'
require './lib/call_aggregation'


class Dataset

  attr_reader :raw_calls

  include CallDetails
  include CallAggregation


  def initialize(calls)
    @raw_calls = calls
  end


  def to_hash
    { 'max_delay'              => max_delay_hash,
      'queued_calls'           => queued_calls_hash,
      'average_delay'          => average_delay_hash,
      'dispatched_calls'       => dispatched_calls_hash,
      'active_call_count'      => active_call_count,
      'queued_call_count'      => queued_call_count,
      'pre_queued_call_count'  => pre_queued_call_count,
      'dispatched_call_count'  => dispatched_call_count,
      'queued_calls_delay_max' => queued_calls_delay_max,
      'queued_calls_delay_avg' => queued_calls_delay_avg
    }
  end


  def store
    Dataset.dataset = self.to_hash
  end


  def self.dataset=(val)
    @dataset = val
  end


  def self.fetch
    @dataset || {}
  end
end
